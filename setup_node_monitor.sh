#!/bin/bash

# Function to prompt for a variable
prompt_variable() {
    local var_name=$1
    local var_description=$2
    local default_value=$3
    local user_input

    if [ -n "$default_value" ]; then
        read -p "$var_description [$default_value]: " user_input
        eval $var_name="${user_input:-$default_value}"
    else
        while [ -z "${!var_name}" ]; do
            read -p "$var_description: " user_input
            eval $var_name="$user_input"
        done
    fi
}

# Welcome message
echo "Welcome to the Node Monitor Setup!"
echo "This script will guide you through setting up the Node Monitor."
echo

# Create directory if it doesn't exist
sudo mkdir -p /root/node.monitor

# Prompt for variables
prompt_variable NODE_WALLET_ID "Enter your Node Wallet ID"
prompt_variable ONLINE_STATUS_URL "Enter the Online Status URL" "https://api-testnet.lilypad.tech/metrics-dashboard/nodes"
prompt_variable POW_SIGNAL_URL "Enter the PoW Signal URL" "https://api-sepolia.arbiscan.io/api"
prompt_variable TELEGRAM_BOT_TOKEN "Enter your Telegram Bot Token"
prompt_variable TELEGRAM_CHAT_ID "Enter your Telegram Chat ID"
prompt_variable COOLDOWN_PERIOD "Enter the cooldown period in seconds" "3600"
prompt_variable POW_COOLDOWN_PERIOD "Enter the PoW check cooldown period in seconds" "3600"
prompt_variable TESTING_MODE "Enable testing mode? (true/false)" "false"

# Create .env file
cat > /root/node.monitor/.env << EOL
NODE_WALLET_ID=$NODE_WALLET_ID
ONLINE_STATUS_URL="$ONLINE_STATUS_URL"
POW_SIGNAL_URL="$POW_SIGNAL_URL"
TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
TELEGRAM_CHAT_ID=$TELEGRAM_CHAT_ID
COOLDOWN_PERIOD=$COOLDOWN_PERIOD
POW_COOLDOWN_PERIOD=$POW_COOLDOWN_PERIOD
TESTING_MODE=$TESTING_MODE
EOL

echo ".env file created successfully."

# Download the main script
curl -o /root/node.monitor/node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/node_monitor.sh
chmod +x /root/node.monitor/node_monitor.sh

echo "Main script downloaded and made executable."

# Create systemd service file
cat > /etc/systemd/system/node_monitor.service << EOL
[Unit]
Description=Node Monitor Service
After=network.target

[Service]
ExecStart=/bin/bash -c '/root/node.monitor/node_monitor.sh'
Restart=always
User=root
Group=root
Environment=PATH=/usr/bin:/usr/local/bin
WorkingDirectory=/root/node.monitor
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOL

echo "Systemd service file created."

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable node_monitor.service
systemctl start node_monitor.service

echo "Node Monitor service enabled and started."

echo "Setup complete! Your Node Monitor is now running."
echo "You can check its status with: systemctl status node_monitor.service"
echo "And view logs with: journalctl -u node_monitor.service -f"
