variable "project_id" {
  description = "The Google Cloud project ID"
  type        = string
  default     = "sandbox-juangar"
}

variable "region" {
  description = "The Google Cloud region"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The Google Cloud zone for the VM instance"
  type        = string
  default     = "us-central1-a"
}

variable "instance_name" {
  description = "Name of the VS Code tunnel VM instance"
  type        = string
  default     = "vscode-tunnel-vm"
}

variable "machine_type" {
  description = "Machine type for the VM (e2-micro is free tier eligible)"
  type        = string
  default     = "e2-micro"
}

variable "boot_disk_image" {
  description = "Boot disk image for the VM"
  type        = string
  default     = "ubuntu-os-cloud/ubuntu-2204-lts"
}

variable "boot_disk_size" {
  description = "Boot disk size in GB (30GB is free tier limit)"
  type        = number
  default     = 30
}
