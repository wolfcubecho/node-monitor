#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Function to prompt for a variable if it's not set
prompt_variable() {
    local var_name="$1"
    local prompt_text="$2"
    if [ -z "${!var_name}" ]; then
        read -p "$prompt_text: " value
        eval "$var_name='$value'"
    fi
}

echo "Starting Node Monitor Setup..."

# Prompt for variables if they're not set
prompt_variable NODE_WALLET_ID "Enter your Node Wallet ID"
prompt_variable TELEGRAM_BOT_TOKEN "Enter your Telegram Bot Token"
prompt_variable TELEGRAM_CHAT_ID "Enter your Telegram Chat ID"

echo "Creating directory..."
sudo mkdir -p /root/node.monitor

echo "Setting predefined values..."
ONLINE_STATUS_URL="https://api-testnet.lilypad.tech/metrics-dashboard/nodes"
POW_SIGNAL_URL="https://api-sepolia.arbiscan.io/api"
COOLDOWN_PERIOD=3600  # 1 hour in seconds
POW_COOLDOWN_PERIOD=3600  # 1 hour in seconds
TESTING_MODE=false

echo "Creating .env file..."
sudo tee /root/node.monitor/.env > /dev/null << EOF
NODE_WALLET_ID="${NODE_WALLET_ID}"
ONLINE_STATUS_URL="${ONLINE_STATUS_URL}"
POW_SIGNAL_URL="${POW_SIGNAL_URL}"
TELEGRAM_BOT_TOKEN="${TELEGRAM_BOT_TOKEN}"
TELEGRAM_CHAT_ID="${TELEGRAM_CHAT_ID}"
COOLDOWN_PERIOD=${COOLDOWN_PERIOD}
POW_COOLDOWN_PERIOD=${POW_COOLDOWN_PERIOD}
TESTING_MODE=${TESTING_MODE}
EOF

echo ".env file created successfully."

echo "Downloading main script..."
sudo curl -o /root/node.monitor/node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/node_monitor.sh
sudo chmod +x /root/node.monitor/node_monitor.sh

echo "Main script downloaded and made executable."

echo "Creating systemd service file..."
sudo tee /etc/systemd/system/node_monitor.service > /dev/null << EOF
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
EOF

echo "Systemd service file created."

echo "Reloading systemd, enabling and starting the service..."
sudo systemctl daemon-reload
sudo systemctl enable node_monitor.service
sudo systemctl start node_monitor.service

echo "Setup complete! Your Node Monitor is now running."
echo "You can check its status with: systemctl status node_monitor.service"
echo "And view logs with: journalctl -u node_monitor.service -f"
