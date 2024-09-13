#!/bin/bash

# Ensure the script is sourced if piped to bash
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ "${0}" == "bash" ]]; then
        source /dev/stdin
        exit 0
    fi
fi

set -e  # Exit immediately if a command exits with a non-zero status.

echo "Starting setup script..."

# Function to prompt for a variable
prompt_variable() {
    local var_name="$1"
    local var_description="$2"
    local user_input

    while [ -z "${!var_name}" ]; do
        read -p "$var_description: " user_input
        eval "$var_name='$user_input'"
    done
}

echo "Welcome to the Node Monitor Setup!"
echo "This script will guide you through setting up the Node Monitor."
echo

echo "Creating directory..."
sudo mkdir -p /root/node.monitor

echo "Setting predefined values..."
ONLINE_STATUS_URL="https://api-testnet.lilypad.tech/metrics-dashboard/nodes"
POW_SIGNAL_URL="https://api-sepolia.arbiscan.io/api"
COOLDOWN_PERIOD=3600  # 1 hour in seconds
POW_COOLDOWN_PERIOD=3600  # 1 hour in seconds
TESTING_MODE=false

echo "Prompting for variables..."
prompt_variable NODE_WALLET_ID "Enter your Node Wallet ID"
prompt_variable TELEGRAM_BOT_TOKEN "Enter your Telegram Bot Token"
prompt_variable TELEGRAM_CHAT_ID "Enter your Telegram Chat ID"

echo "Creating .env file..."
sudo tee /root/node.monitor/.env > /dev/null << EOL
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

echo "Downloading main script..."
sudo curl -o /root/node.monitor/node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/node_monitor.sh
sudo chmod +x /root/node.monitor/node_monitor.sh

echo "Main script downloaded and made executable."

echo "Creating systemd service file..."
sudo tee /etc/systemd/system/node_monitor.service > /dev/null << EOL
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

echo "Reloading systemd, enabling and starting the service..."
sudo systemctl daemon-reload
sudo systemctl enable node_monitor.service
sudo systemctl start node_monitor.service

echo "Setup complete! Your Node Monitor is now running."
echo "You can check its status with: systemctl status node_monitor.service"
echo "And view logs with: journalctl -u node_monitor.service -f"
