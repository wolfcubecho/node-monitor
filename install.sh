#!/bin/bash

# Store the script's path
SCRIPT_PATH="$0"

echo "Downloading Node Monitor setup script..."
curl -s -o setup_node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/setup_node_monitor.sh
chmod +x setup_node_monitor.sh

echo "Running setup script..."
sudo ./setup_node_monitor.sh

echo "Cleaning up..."
if [ "$SCRIPT_PATH" != "bash" ]; then
    rm -f "$SCRIPT_PATH"
    echo "Install script has been removed."
fi

echo "Installation complete!"
