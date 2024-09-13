# Lilypad Node Monitor

This repository contains a Node Monitor script for Lilypad nodes. It checks the online status of your node, monitors Proof of Work (PoW) signals, and sends alerts via Telegram if any issues are detected.

## Features

- Monitors node online status
- Checks for recent PoW signals
- Sends alerts via Telegram
- Automatically restarts services if issues are detected
- Configurable cooldown periods to prevent excessive restarts

## Requirements

- Linux system (Ubuntu 20.04 or later recommended)
- Root access (sudo)
- curl
- jq
- Telegram bot (for alerts)

## Installation

1. Ensure you're using a Linux system with sudo access.

2. Open a terminal on your server.

3. Run the following command to download and execute the setup script:

   ```bash
   curl -s https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/setup_node_monitor.sh | sudo bash
   ```

4. Follow the prompts to enter your node's details and Telegram bot information. You'll need:
   - Your Node Wallet ID
   - Telegram Bot Token
   - Telegram Chat ID
   - (The script will provide default values for other settings)

5. Once complete, the Node Monitor service will start automatically.

## Usage

After installation, the Node Monitor runs as a system service. You can manage it using systemctl commands:

- Check the status:
  ```bash
  sudo systemctl status node_monitor.service
  ```

- View logs in real-time:
  ```bash
  sudo journalctl -u node_monitor.service -f
  ```

- Restart the service:
  ```bash
  sudo systemctl restart node_monitor.service
  ```

## Configuration

The setup script creates a `.env` file in `/root/node.monitor/` with your configuration. If you need to change any settings, edit this file and restart the service.

## Updating

To update the Node Monitor, simply run the setup script again:

```bash
curl -s https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/setup_node_monitor.sh | sudo bash
```

This will fetch the latest version of the monitor script and update your installation.

## Troubleshooting

If you encounter any issues:

1. Check the service status and logs as shown in the Usage section.
2. Ensure all the information you provided during setup was correct.
3. Verify your internet connection and that your Telegram bot is functioning.

## Security Notes

- Keep your Telegram Bot Token and other sensitive information private.
- The script runs with root privileges. Ensure you trust the source (this repository) before running the setup script.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Support

If you encounter any problems or have any questions, please open an issue in this repository.

## License

[MIT License](LICENSE)
