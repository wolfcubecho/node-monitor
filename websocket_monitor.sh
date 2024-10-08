#!/bin/bash

# Load environment variables from .env file
if [ -f "$(dirname "$0")/.env" ]; then
    export $(grep -v '^#' "$(dirname "$0")/.env" | xargs)
else
    echo "Error: .env file not found"
    exit 1
fi

# Check if required variables are set
if [ -z "$INFURA_PROJECT_ID" ] || [ -z "$TELEGRAM_BOT_TOKEN" ] || [ -z "$TELEGRAM_CHAT_ID" ]; then
    echo "Error: Required environment variables are not set in .env file"
    exit 1
fi

WEBSOCKET_URL="wss://arbitrum-mainnet.infura.io/ws/v3/$INFURA_PROJECT_ID"
LAST_PING_FILE="/tmp/last_websocket_ping"
WEBSOCKET_ALERT_FILE="/tmp/websocket_alert"
CHECK_INTERVAL=900  # Check every 15 minutes (900 seconds)
ALERT_THRESHOLD=3960  # Alert if no ping for 1.1 hours (3960 seconds)

echo "Starting WebSocket monitor..."
echo "Using WebSocket URL: $WEBSOCKET_URL"
echo "INFURA_PROJECT_ID: $INFURA_PROJECT_ID"

# Function to write alert to file (instead of sending directly)
write_alert() {
    local message="$1"
    echo "$message" > "$WEBSOCKET_ALERT_FILE"
    echo "Alert file created: $message"
}

# Function to handle WebSocket connection
handle_websocket() {
    (
        echo '{"jsonrpc":"2.0","id": 1, "method": "eth_subscribe", "params": ["newHeads"]}'
        while true; do
            sleep 30
            echo '{"jsonrpc":"2.0","id": 2, "method": "eth_blockNumber", "params": []}'
        done
    ) | wscat -c "$WEBSOCKET_URL" 2>&1 | while read -r line; do
        echo "Received: $line"
        if [[ $line == *"error"* || $line == *"Error"* ]]; then
            echo "Error detected in WebSocket connection"
            write_alert "Error in WebSocket connection: $line"
            return 1
        elif [[ $line == *"connected"* ]]; then
            echo "Connection established."
        elif [[ $line == *"result"* ]]; then
            echo "$(date +%s)" > "$LAST_PING_FILE"
            echo "Ping received at $(date)"
        fi
    done
}

# Function to check last ping time and write alert if necessary
check_last_ping() {
    if [ -f "$LAST_PING_FILE" ]; then
        last_ping=$(cat "$LAST_PING_FILE")
        current_time=$(date +%s)
        time_diff=$((current_time - last_ping))
        
        if [ $time_diff -gt $ALERT_THRESHOLD ]; then
            message="No WebSocket ping received in the last $(($time_diff / 60)) minutes."
            echo "$message"
            write_alert "$message"
        else
            echo "Last ping was $time_diff seconds ago. All is well."
        fi
    else
        echo "No ping file found. WebSocket connection may not be established yet."
        write_alert "WebSocket connection not established. No ping file found."
    fi
}

# Start WebSocket handling in the background
handle_websocket &

# Main loop for checking pings
while true; do
    check_last_ping
    sleep $CHECK_INTERVAL
done
