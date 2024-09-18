#!/bin/bash

echo "Downloading Node Monitor setup script..."
curl -o setup_node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/setup_node_monitor.sh
chmod +x setup_node_monitor.sh

echo "Download complete. To set up the Node Monitor, run:"
echo "sudo ./setup_node_monitor.sh"
