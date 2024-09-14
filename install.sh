#!/bin/bash

# Download the setup script
curl -o setup_node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/setup_node_monitor.sh

# Make it executable
chmod +x setup_node_monitor.sh

# Run the setup script
sudo ./setup_node_monitor.sh

# Clean up
rm setup_node_monitor.sh
