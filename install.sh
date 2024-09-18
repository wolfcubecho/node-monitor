#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

# Store the script's path
SCRIPT_PATH="$0"

# Function to prompt for a variable
prompt_variable() {
    local var_name="$1"
    local prompt_text="$2"
    local value

    while true; do
        read -p "$prompt_text: " value
        if [ -n "$value" ]; then
            eval "$var_name='$value'"
            break
        else
            echo "Input cannot be empty. Please try again."
        fi
    done
}

echo "Starting Node Monitor Setup..."

prompt_variable NODE_WALLET_ID "Enter your Node Wallet ID"
prompt_variable TELEGRAM_BOT_TOKEN "Enter your Telegram Bot Token"
prompt_variable TELEGRAM_CHAT_ID "Enter your Telegram Chat ID"

echo "Downloading Node Monitor setup script..."
curl -s -o setup_node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/setup_node_monitor.sh
chmod +x setup_node_monitor.sh

echo "Running setup script..."
sudo NODE_WALLET_ID="$NODE_WALLET_ID" TELEGRAM_BOT_TOKEN="$TELEGRAM_BOT_TOKEN" TELEGRAM_CHAT_ID="$TELEGRAM_CHAT_ID" ./setup_node_monitor.sh

echo "Cleaning up..."
rm setup_node_monitor.sh

# Self-delete if not piped to bash
if [ "$SCRIPT_PATH" != "bash" ]; then
    rm -f "$SCRIPT_PATH"
    echo "Install script has been removed."
fi

echo "Installation complete!"
