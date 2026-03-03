output "state_bucket_name" {
  description = "Name of the Terraform state bucket"
  value       = google_storage_bucket.terraform_state.name
}

output "state_bucket_url" {
  description = "URL of the Terraform state bucket"
  value       = google_storage_bucket.terraform_state.url
}

output "wif_provider" {
  description = "WIF provider resource name — set as WIF_PROVIDER GitHub secret"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "service_account_gke" {
  description = "GKE service account email — set as WIF_SERVICE_ACCOUNT_GKE GitHub secret"
  value       = google_service_account.terraform_gke.email
}

output "service_account_gcs" {
  description = "GCS service account email — set as WIF_SERVICE_ACCOUNT_GCS GitHub secret"
  value       = google_service_account.terraform_gcs.email
}
