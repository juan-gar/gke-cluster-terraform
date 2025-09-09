variable "project_id" {
  description = "The Google Cloud project ID to deploy the resources in."
  type        = string
  default     = "juangar-sandbox"
}

variable "region" {
  description = "The Google Cloud region for resources."
  type        = string
  default     = "us-central1"
}

variable "service_account_email" {
  description = "The service account email that will access the state bucket."
  type        = string
}