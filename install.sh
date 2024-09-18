#!/bin/bash

set -x  # Enable debugging

echo "Downloading Node Monitor setup script..."
curl -s -o setup_node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/setup_node_monitor.sh
ls -l setup_node_monitor.sh  # Check if the file was downloaded

echo "Making setup script executable..."
chmod +x setup_node_monitor.sh
ls -l setup_node_monitor.sh  # Check permissions

echo "Running setup script..."
sudo bash -x ./setup_node_monitor.sh

echo "Installation complete!"
