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

# Node Monitor

## Installation

To install the Node Monitor, run the following command:

```bash
curl -s https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/install.sh | bash
```

This will download and run the installation script. You will be prompted to enter:

1. Your Node Wallet ID
2. Your Telegram Bot Token
3. Your Telegram Chat ID

Follow the prompts and provide the required information.

## Usage

After installation, you can:

- Check the status of the monitor:
  ```
  sudo systemctl status node_monitor.service
  ```

- View the logs:
  ```
  sudo journalctl -u node_monitor.service -f
  ```

For more detailed information, please refer to the full documentation.

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
