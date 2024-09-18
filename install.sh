#!/bin/bash

set -x  # Enable debugging

echo "Setup script started"
pwd  # Print current directory
ls -l  # List files in current directory

echo "Downloading Node Monitor setup script..."
curl -s -o setup_node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/setup_node_monitor.sh
chmod +x setup_node_monitor.sh

echo "Running setup script..."
sudo ./setup_node_monitor.sh

echo "Installation complete!"
