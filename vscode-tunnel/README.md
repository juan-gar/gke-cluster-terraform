# VS Code Tunnel VM

This directory contains Terraform configuration to deploy a free-tier Google Cloud VM that runs VS Code tunnel, allowing you to access VS Code in your browser from anywhere.

## Overview

This setup creates:
- An `e2-micro` VM instance (free tier eligible)
- A dedicated service account for the VM
- Firewall rules for HTTPS and SSH access
- Automatic installation of VS Code CLI
- A systemd service for running the tunnel

## Prerequisites

- Google Cloud project with billing enabled
- Workload Identity Federation configured
- Terraform state bucket created
- GitHub secrets configured:
  - `WIF_PROVIDER`
  - `WIF_SERVICE_ACCOUNT_GKE`

## Free Tier Eligibility

This configuration uses:
- `e2-micro` instance in `us-central1` (free tier eligible)
- 30GB standard persistent disk (within free tier limit)
- Standard network tier

## Deployment

### Via GitHub Actions

1. Go to the Actions tab in GitHub
2. Select "VS Code Tunnel - Deploy" workflow
3. Click "Run workflow"
4. Select action: `apply` to create or `destroy` to delete
5. Click "Run workflow" button

### Via Local Terraform

```bash
cd vscode-tunnel
terraform init \
  -backend-config="bucket=sandbox-juangar-terraform-state" \
  -backend-config="prefix=terraform/vscode-tunnel"
terraform plan
terraform apply
```

## Setup Instructions

After the VM is deployed, you need to authenticate the VS Code tunnel:

1. SSH into the VM:
   ```bash
   gcloud compute ssh vscode-tunnel-vm --zone=us-central1-a
   ```

2. Switch to the vscode-tunnel user:
   ```bash
   sudo su - vscode-tunnel
   ```

3. Start the tunnel and authenticate:
   ```bash
   code tunnel --accept-server-license-terms
   ```

4. You'll see output like:
   ```
   * To grant access to the server, please log into https://github.com/login/device
     and use code XXXX-XXXX
   ```

5. Visit the URL and enter the code to authenticate

6. Once authenticated, exit the user session and enable the service:
   ```bash
   exit
   sudo systemctl enable vscode-tunnel
   sudo systemctl start vscode-tunnel
   ```

## Accessing Your VS Code Tunnel

After authentication, access your VS Code environment at:
```
https://vscode.dev/tunnel/<machine-name>
```

The machine name is `vscode-tunnel-vm` by default.

## Managing the Service

### Check service status:
```bash
sudo systemctl status vscode-tunnel
```

### View logs:
```bash
sudo journalctl -u vscode-tunnel -f
```

### Restart service:
```bash
sudo systemctl restart vscode-tunnel
```

### Stop service:
```bash
sudo systemctl stop vscode-tunnel
```

## Cost Considerations

While the e2-micro instance is free tier eligible, be aware of:
- Free tier includes 1 e2-micro instance per month in specific regions
- Network egress charges may apply beyond free tier limits
- External IP addresses may incur charges

Always monitor your GCP billing dashboard.

## Cleanup

To destroy the resources:

Via GitHub Actions:
1. Go to Actions → "VS Code Tunnel - Deploy"
2. Run workflow with action: `destroy`

Via local Terraform:
```bash
cd vscode-tunnel
terraform destroy
```

## Troubleshooting

### Can't connect to tunnel
- Check if the service is running: `sudo systemctl status vscode-tunnel`
- Verify authentication: `sudo su - vscode-tunnel` then `code tunnel status`
- Check logs: `sudo journalctl -u vscode-tunnel -f`

### Startup script issues
- View startup script logs: `sudo journalctl -u google-startup-scripts.service`
- Check the log file: `sudo cat /var/log/vscode-tunnel-setup.log`

### Firewall issues
- Verify firewall rules: `gcloud compute firewall-rules list | grep vscode-tunnel`
- Ensure HTTPS (443) is allowed

## Security Notes

- The VM uses OS Login for SSH access
- A dedicated service account is created with minimal permissions
- Firewall rules allow HTTPS from any IP (required for tunnel access)
- Consider restricting SSH access to specific IPs if needed
