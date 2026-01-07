terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  backend "gcs" {
    bucket = "sandbox-juangar-terraform-state"
    prefix = "terraform/vscode-tunnel"
  }
}

# Configure the Google Cloud provider
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create a service account for the VS Code tunnel VM
resource "google_service_account" "vscode_tunnel" {
  account_id   = "vscode-tunnel-sa"
  display_name = "VS Code Tunnel Service Account"
  description  = "Service account for VS Code tunnel VM"
}

# Create firewall rule to allow HTTPS traffic (required for VS Code tunnel)
resource "google_compute_firewall" "vscode_tunnel_https" {
  name    = "vscode-tunnel-allow-https"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vscode-tunnel"]
}

# Create firewall rule to allow SSH
resource "google_compute_firewall" "vscode_tunnel_ssh" {
  name    = "vscode-tunnel-allow-ssh"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["vscode-tunnel"]
}

# Create the VM instance for VS Code tunnel
resource "google_compute_instance" "vscode_tunnel" {
  name         = var.instance_name
  machine_type = var.machine_type
  zone         = var.zone

  # Use free tier eligible boot disk
  boot_disk {
    initialize_params {
      image = var.boot_disk_image
      size  = var.boot_disk_size
      type  = "pd-standard" # Standard persistent disk (free tier eligible)
    }
  }

  # Network configuration
  network_interface {
    network = "default"

    # Assign an ephemeral external IP
    access_config {
      network_tier = "STANDARD" # Standard tier for free tier eligibility
    }
  }

  # Service account configuration
  service_account {
    email  = google_service_account.vscode_tunnel.email
    scopes = ["cloud-platform"]
  }

  # Tags for firewall rules
  tags = ["vscode-tunnel"]

  # Metadata startup script to install and configure VS Code tunnel
  metadata_startup_script = file("${path.module}/startup-script.sh")

  # Metadata for SSH keys and other configuration
  metadata = {
    enable-oslogin = "TRUE"
  }

  # Allow stopping the instance to update it
  allow_stopping_for_update = true

  labels = {
    environment = "development"
    purpose     = "vscode-tunnel"
  }
}
