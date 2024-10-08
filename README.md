# Lilypad Node Monitor

## Overview

This Node Monitor is a comprehensive tool designed for Lilypad network participants. It performs several key functions:

1. Monitors the online status of your Lilypad node
2. Checks for recent Proof of Work (PoW) signals
3. Maintains a WebSocket connection to an Arbitrum node via Infura for real-time updates
4. Sends alerts via Telegram if any issues are detected

## Features

- Checks node online status through Lilypad's API
- Monitors for recent PoW signals to ensure node activity
- Maintains a persistent WebSocket connection to Arbitrum for real-time block updates
- Sends alerts via Telegram for various issues:
  - Node going offline
  - Lack of recent PoW signals
  - Loss of WebSocket connection
- Automatically attempts to restart services if problems are detected
- Configurable check intervals and alert thresholds

## Prerequisites

- Ubuntu 20.04 or later
- Node.js and npm
- `wscat` (WebSocket client)
- Curl
- jq (for JSON processing)
- A Telegram Bot Token and Chat ID
- An Infura Project ID with access to Arbitrum
- A Lilypad node set up and running

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/your-repo/lilypad-node-monitor.git
   cd lilypad-node-monitor
   ```

2. Install the required dependencies:
   ```bash
   sudo apt-get update
   sudo apt-get install -y nodejs npm curl jq
   sudo npm install -g wscat
   ```

3. Set up your environment variables. Create a `.env` file in the project directory:
   ```
   NODE_WALLET_ID=your_lilypad_node_wallet_id
   TELEGRAM_BOT_TOKEN=your_telegram_bot_token
   TELEGRAM_CHAT_ID=your_telegram_chat_id
   INFURA_PROJECT_ID=your_infura_project_id
   ONLINE_STATUS_URL=https://api-testnet.lilypad.tech/metrics-dashboard/nodes
   POW_SIGNAL_URL=https://api-sepolia.arbiscan.io/api
   ```

4. Edit the `node_monitor.sh` and `websocket_monitor.sh` scripts to ensure all paths and configurations are correct.

5. Make the scripts executable:
   ```bash
   chmod +x node_monitor.sh websocket_monitor.sh
   ```

6. Set up the systemd services for both monitors. Create two service files:
   ```bash
   sudo nano /etc/systemd/system/node-monitor.service
   sudo nano /etc/systemd/system/websocket-monitor.service
   ```
   Add the appropriate content to each, similar to:
   ```
   [Unit]
   Description=Lilypad Node Monitor Service
   After=network.target

   [Service]
   Type=simple
   ExecStart=/bin/bash /path/to/your/node_monitor.sh
   Restart=always
   User=root
   Group=root
   Environment=PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
   WorkingDirectory=/path/to/your/script/directory

   [Install]
   WantedBy=multi-user.target
   ```

7. Reload systemd, enable and start the services:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable node-monitor.service websocket-monitor.service
   sudo systemctl start node-monitor.service websocket-monitor.service
   ```

## Usage

Both monitor services will run automatically. You can check their status with:

```bash
sudo systemctl status node-monitor.service
sudo systemctl status websocket-monitor.service
```

View the logs:

```bash
sudo journalctl -u node-monitor.service -f
sudo journalctl -u websocket-monitor.service -f
```

## Configuration

You can adjust various parameters in both `node_monitor.sh` and `websocket_monitor.sh` scripts:

- Check intervals
- Alert thresholds
- Cooldown periods for restarts

Refer to the comments in each script for details on what each parameter does.

## Troubleshooting

1. If services fail to start, check the logs for error messages.
2. Ensure all environment variables in the `.env` file are correctly set.
3. Verify your Infura Project ID has access to Arbitrum and WebSocket connections are enabled.
4. Test Telegram notifications manually to ensure the bot token and chat ID are correct.
5. Check that your Lilypad node is properly set up and the wallet ID is correct.

## Contributing

Contributions to improve the Node Monitor are welcome. Please feel free to submit pull requests or open issues for bugs and feature requests.

## License

[Specify your license here, e.g., MIT License]

## Additional Information

This node monitor is an essential tool for Lilypad network participants. It helps ensure your node remains active and responsive, contributing effectively to the network. By monitoring multiple aspects of node operation, including online status, PoW signals, and real-time blockchain updates, it provides comprehensive oversight of your Lilypad node's health and performance.

For more information about Lilypad and how to set up a node, please refer to the official Lilypad documentation.
