#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

echo "Downloading Node Monitor setup script..."
curl -o setup_node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/setup_node_monitor.sh
chmod +x setup_node_monitor.sh

echo "To complete the setup, run the following command:"
echo "sudo ./setup_node_monitor.sh"

echo "After running the setup, you can delete the setup script with:"
echo "rm setup_node_monitor.sh"
