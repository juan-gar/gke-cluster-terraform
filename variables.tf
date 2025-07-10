variable "project_id" {
  description = "The Google Cloud project ID to deploy the resources in."
  type        = string
  default     = "juangar-sandbox"  # Replace with your actual project ID
}

variable "region" {
  description = "The Google Cloud region for the GKE cluster."
  type        = string
  default     = "us-central1"
}

variable "machine_type" {
  description = "The machine type for the GKE nodes."
  type        = string
  default     = "e2-medium"
}

variable "node_count" {
  description = "The number of nodes in the custom node pool."
  type        = number
  default     = 2
}