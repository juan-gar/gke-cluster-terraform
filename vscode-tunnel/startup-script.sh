#!/bin/bash
set -e

# Log file for debugging
LOGFILE="/var/log/vscode-tunnel-setup.log"
exec > >(tee -a ${LOGFILE}) 2>&1

echo "Starting VS Code Tunnel setup at $(date)"

# Update system packages
echo "Updating system packages..."
apt-get update
apt-get upgrade -y

# Install required dependencies
echo "Installing dependencies..."
apt-get install -y curl wget gpg apt-transport-https

# Download and install VS Code CLI
echo "Downloading VS Code CLI..."
cd /tmp
curl -Lk 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64' --output vscode_cli.tar.gz

# Extract VS Code CLI
echo "Extracting VS Code CLI..."
tar -xf vscode_cli.tar.gz

# Move to system path
echo "Installing VS Code CLI..."
mv code /usr/local/bin/
chmod +x /usr/local/bin/code

# Verify installation
echo "Verifying VS Code CLI installation..."
code --version

# Create a dedicated user for running the tunnel
echo "Creating vscode tunnel user..."
if ! id -u vscode-tunnel > /dev/null 2>&1; then
    useradd -m -s /bin/bash vscode-tunnel
fi

# Create systemd service for VS Code tunnel
echo "Creating systemd service..."
cat > /etc/systemd/system/vscode-tunnel.service <<'EOF'
[Unit]
Description=VS Code Tunnel
After=network.target

[Service]
Type=simple
User=vscode-tunnel
WorkingDirectory=/home/vscode-tunnel
ExecStart=/usr/local/bin/code tunnel --accept-server-license-terms --name vscode-tunnel-vm
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
echo "Reloading systemd..."
systemctl daemon-reload

# Note: The tunnel service needs manual authentication on first run
# Users need to SSH into the VM and run: sudo systemctl start vscode-tunnel
# Then check logs with: sudo journalctl -u vscode-tunnel -f
# They will see an authentication URL to visit

echo "VS Code Tunnel setup completed at $(date)"
echo ""
echo "==================================================================="
echo "IMPORTANT: Manual authentication required!"
echo "==================================================================="
echo "To complete the setup:"
echo "1. SSH into this VM"
echo "2. Switch to vscode-tunnel user: sudo su - vscode-tunnel"
echo "3. Run: code tunnel --accept-server-license-terms"
echo "4. Follow the authentication URL displayed"
echo "5. After authentication, exit and enable the service:"
echo "   sudo systemctl enable vscode-tunnel"
echo "   sudo systemctl start vscode-tunnel"
echo "==================================================================="
