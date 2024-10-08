# Node Monitor

## Installation

To install the Node Monitor, follow these steps:

1. Run the installation script:
   ```bash
   curl -s https://raw.githubusercontent.com/wolfcubecho/node-monitor/main/install.sh | sudo bash
   ```

2. The script will prompt you for the following information:
   - Node Wallet ID
   - Telegram Bot Token
   - Telegram Chat ID

3. After the main installation, set up the WebSocket monitoring:

   a. Install Node.js and npm:
      ```bash
      sudo apt-get update
      sudo apt-get install -y nodejs npm
      ```

   b. Install wscat globally:
      ```bash
      sudo npm install -g wscat
      ```

   c. Create the WebSocket monitor script:
      ```bash
      sudo nano /root/node.monitor/websocket_monitor.sh
      ```
      Paste the content of the WebSocket monitor script (provided separately) into this file.

   d. Make the script executable:
      ```bash
      sudo chmod +x /root/node.monitor/websocket_monitor.sh
      ```

   e. Create a systemd service for the WebSocket monitor:
      ```bash
      sudo nano /etc/systemd/system/websocket-monitor.service
      ```
      Paste the systemd service configuration (provided separately) into this file.

   f. Enable and start the WebSocket monitor service:
      ```bash
      sudo systemctl daemon-reload
      sudo systemctl enable websocket-monitor.service
      sudo systemctl start websocket-monitor.service
      ```

## Usage

After installation, you can:

- Check the status of the main monitor:
  ```
  sudo systemctl status node_monitor.service
  ```

- Check the status of the WebSocket monitor:
  ```
  sudo systemctl status websocket-monitor.service
  ```

- View the logs of the main monitor:
  ```
  sudo journalctl -u node_monitor.service -f
  ```

- View the logs of the WebSocket monitor:
  ```
  sudo journalctl -u websocket-monitor.service -f
  ```

## Testing WebSocket Monitoring

To test if the WebSocket monitoring is working:

1. Check if the WebSocket monitor is running:
   ```bash
   sudo systemctl status websocket-monitor.service
   ```

2. View the WebSocket monitor logs:
   ```bash
   sudo journalctl -u websocket-monitor.service -f
   ```
   You should see messages about received pings.

3. Check the last ping time:
   ```bash
   cat /tmp/last_websocket_ping
   ```
   This should show a recent timestamp.

4. To test the alert, you can temporarily modify the `LAST_PING_FILE`:
   ```bash
   sudo bash -c 'echo $(($(date +%s) - 4000)) > /tmp/last_websocket_ping'
   ```
   This sets the last ping time to more than 1.1 hours ago.

5. Wait for the next check cycle of the main monitor (up to 5 minutes) or restart it:
   ```bash
   sudo systemctl restart node_monitor.service
   ```

6. Check the main monitor logs:
   ```bash
   sudo journalctl -u node_monitor.service -f
   ```
   You should see a message about no WebSocket ping received and an alert being sent to Telegram.

7. Check your Telegram for the alert message.

Remember to revert the `LAST_PING_FILE` to its current time after testing:
```bash
sudo bash -c 'echo $(date +%s) > /tmp/last_websocket_ping'
```

For more detailed information, please refer to the full documentation.
