output "instance_name" {
  description = "Name of the VS Code tunnel VM instance"
  value       = google_compute_instance.vscode_tunnel.name
}

output "instance_zone" {
  description = "Zone where the VM instance is running"
  value       = google_compute_instance.vscode_tunnel.zone
}

output "external_ip" {
  description = "External IP address of the VM instance"
  value       = google_compute_instance.vscode_tunnel.network_interface[0].access_config[0].nat_ip
}

output "internal_ip" {
  description = "Internal IP address of the VM instance"
  value       = google_compute_instance.vscode_tunnel.network_interface[0].network_ip
}

output "service_account_email" {
  description = "Service account email for the VS Code tunnel VM"
  value       = google_service_account.vscode_tunnel.email
}

output "tunnel_setup_instructions" {
  description = "Instructions to check the VS Code tunnel setup"
  value       = <<-EOT
    To check the VS Code tunnel setup status:
    1. SSH into the VM: gcloud compute ssh ${google_compute_instance.vscode_tunnel.name} --zone=${google_compute_instance.vscode_tunnel.zone}
    2. Check the startup script logs: sudo journalctl -u google-startup-scripts.service
    3. Check VS Code CLI status: code tunnel status

    To authenticate and start using the tunnel:
    1. SSH into the VM
    2. Run: code tunnel user login
    3. Follow the authentication prompts
    4. Your tunnel will be accessible via https://vscode.dev/tunnel/<machine-name>
  EOT
}
