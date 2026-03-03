variable "project_id" {
  description = "The Google Cloud project ID."
  type        = string
}

variable "region" {
  description = "The Google Cloud region for resources."
  type        = string
  default     = "us-central1"
}

variable "github_repo" {
  description = "The GitHub repository allowed to authenticate via WIF (owner/repo)."
  type        = string
}

variable "wif_pool_name" {
  description = "The WIF pool resource name from the GCP console (projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID)."
  type        = string
}
