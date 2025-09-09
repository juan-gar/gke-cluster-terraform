output "state_bucket_name" {
  description = "Name of the created state bucket"
  value       = google_storage_bucket.terraform_state.name
}

output "state_bucket_url" {
  description = "URL of the created state bucket"
  value       = google_storage_bucket.terraform_state.url
}