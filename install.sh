#!/bin/bash

set -e  # Exit immediately if a command exits with a non-zero status.

echo "Downloading Node Monitor setup script..."
curl -s -o setup_node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/setup_node_monitor.sh
chmod +x setup_node_monitor.sh

echo "Setup script downloaded. Running it now..."
sudo ./setup_node_monitor.sh

echo "Setup complete. Cleaning up..."
rm setup_node_monitor.sh

echo "Installation complete!"
