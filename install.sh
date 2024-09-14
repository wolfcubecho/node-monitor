#!/bin/bash

# Download the setup script
curl -o setup_node_monitor.sh https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/setup_node_monitor.sh

# Make it executable
chmod +x setup_node_monitor.sh

# Run the setup script in an interactive shell
sudo bash << EOF
#!/bin/bash
exec < /dev/tty > /dev/tty 2> /dev/tty
./setup_node_monitor.sh
EOF

# Clean up
rm setup_node_monitor.sh
