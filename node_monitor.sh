#!/bin/bash

# Load environment variables
if [ -f "$(dirname "$0")/.env" ]; then
    export $(grep -v '^#' "$(dirname "$0")/.env" | xargs)
else
    echo "Error: .env file not found"
    exit 1
fi

# Validate required environment variables
if [ -z "$NODE_WALLET_ID" ] || [ -z "$ONLINE_STATUS_URL" ] || [ -z "$POW_SIGNAL_URL" ] || [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "Error: Missing required environment variables"
    exit 1
fi

COOLDOWN_FILE="/tmp/node-monitor-cooldown"
POW_SIGNAL_URL="${POW_SIGNAL_URL}?module=account&action=txlist&address=${NODE_WALLET_ID}&page=1&offset=1000&sort=desc"

# Log file location
LOG_FILE="/root/node.monitor/node_monitor.log"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Function to send Telegram message
send_telegram_alert() {
    local message="$1"
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" \
        -d chat_id="$TELEGRAM_CHAT_ID" \
        -d text="$message" \
        -d parse_mode="HTML"
}

# Function to check online status
check_online_status() {
    log "Checking online status..."
    log "Node Wallet ID: $NODE_WALLET_ID"

    response=$(curl -s "$ONLINE_STATUS_URL")

    log "Searching for node in API response..."
    node_data=$(echo "$response" | jq -r '.[] | select(.ID == "'"$NODE_WALLET_ID"'")')

    if [ -z "$node_data" ]; then
        log "Warning: No exact match found for Node ID. Trying case-insensitive search..."
        node_data=$(echo "$response" | jq -r '.[] | select(.ID | ascii_downcase == "'"${NODE_WALLET_ID,,}"'")')

        if [ -z "$node_data" ]; then
            log "Error: Node not found in API response. Dumping first 5 node IDs for reference:"
            echo "$response" | jq -r '.[0:5] | .[].ID' | while read -r line; do log "$line"; done
            return 1
        else
            log "Node found with case-insensitive match."
        fi
    else
        log "Node found with exact match."
    fi

    log "Node data:"
    echo "$node_data" | while read -r line; do log "$line"; done

    online_status=$(echo "$node_data" | jq -r '.Online')
    log "Online status: $online_status"

    if [ "$online_status" != "true" ]; then
        log "Node is reported as offline."
        return 1
    fi

    log "Node is reported as online."
    return 0
}

POW_COOLDOWN_FILE="/tmp/pow-cooldown"
POW_COOLDOWN_PERIOD=3600  # 1 hour cooldown for PoW checks

# Function to check PoW signals
check_pow_signals() {
    log "Checking PoW signals..."
    
    # Check if we're still in the cooldown period
    if [ -f "$POW_COOLDOWN_FILE" ]; then
        last_check=$(cat "$POW_COOLDOWN_FILE")
        now=$(date +%s)
        if [ $((now - last_check)) -lt $POW_COOLDOWN_PERIOD ]; then
            log "PoW check cooldown active. Skipping check."
            return 0
        fi
    fi
    
    response=$(curl -s "$POW_SIGNAL_URL")
    now=$(date +%s)
    one_hour_ago=$((now - 3600))
    transactions=$(echo "$response" | jq -r '.result')
    filtered_results=$(echo "$transactions" | jq -r '[.[] | select(.methodId == "0xda8accf9" and (.timeStamp | tonumber) >= '"$one_hour_ago"')]')
    signal_count=$(echo "$filtered_results" | jq -r 'length')
    log "Number of PoW signals in the last hour: $signal_count"
    
    # Update the cooldown file
    echo $now > "$POW_COOLDOWN_FILE"
    
    if [ "$signal_count" -lt 1 ]; then
        log "No PoW signals found."
        return 1
    fi
    log "PoW signals found."
    return 0
}

# Function to restart services with cooldown for PoW signals
restart_services() {
    if [ "$1" == "pow" ]; then
        if [ -f "$COOLDOWN_FILE" ]; then
            last_restart=$(cat "$COOLDOWN_FILE")
            now=$(date +%s)
            if [ $((now - last_restart)) -lt ${COOLDOWN_PERIOD:-3600} ]; then
                log "Restart cooldown period active. Skipping restart for PoW signals."
                return 0
            fi
        fi
        date +%s > "$COOLDOWN_FILE"
    fi
    log "Restarting services..."
    if [ "${TESTING_MODE:-false}" == "true" ]; then
        log "Restarting services in testing mode. No actual restarts performed."
    else
        log "restarting bacalhau."
        sudo systemctl restart bacalhau
        log "restarting lilypad-resource-provider."
        sudo systemctl restart lilypad-resource-provider     
    fi
}

# Main logic
log "Starting node monitor service..."
while true; do
    if ! check_online_status; then
        log "Node appears to be offline. Checking again in 60 seconds..."
        sleep 60
        if ! check_online_status; then
            log "Node still appears to be offline. Initiating restart..."
            send_telegram_alert "⚠️ Alert: Node is offline. Initiating restart..."
            restart_services "online"
            send_telegram_alert "🔄 Restart initiated for offline node."
        else
            log "Node is back online. No restart needed."
        fi
    elif ! check_pow_signals; then
        log "No recent PoW signals. Considering restart..."
        if [ -f "$COOLDOWN_FILE" ]; then
            last_restart=$(cat "$COOLDOWN_FILE")
            now=$(date +%s)
            if [ $((now - last_restart)) -lt ${COOLDOWN_PERIOD:-3600} ]; then
                log "Restart cooldown period active. Skipping restart for PoW signals."
            else
                send_telegram_alert "⚠️ Alert: No recent PoW signals detected. Initiating restart..."
                restart_services "pow"
                send_telegram_alert "🔄 Restart initiated due to lack of PoW signals."
            fi
        else
            send_telegram_alert "⚠️ Alert: No recent PoW signals detected. Initiating restart..."
            restart_services "pow"
            send_telegram_alert "🔄 Restart initiated due to lack of PoW signals."
        fi
    fi

    
    log "Sleeping for 5 minutes before next check..."
    sleep 300
done
