#!/bin/bash

echo "Downloading Node Monitor setup script..."
curl -o setup_node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/setup_node_monitor.sh
chmod +x setup_node_monitor.sh

echo "Running setup script..."
sudo ./setup_node_monitor.sh

echo "Cleaning up..."
rm setup_node_monitor.sh

echo "Installation complete!"
