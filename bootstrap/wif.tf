# ---------- Service Accounts ----------

resource "google_service_account" "terraform_gke" {
  account_id   = "terraform-deploy"
  display_name = "Terraform GKE Deploy"
  description  = "Used by GitHub Actions to deploy GKE infrastructure"

  depends_on = [google_project_service.required_apis]
}

resource "google_service_account" "terraform_gcs" {
  account_id   = "gcs-sa"
  display_name = "Terraform GCS State"
  description  = "Used by GitHub Actions to manage Terraform state bucket"

  depends_on = [google_project_service.required_apis]
}

# ---------- IAM: GKE Service Account ----------

resource "google_project_iam_member" "gke_container_admin" {
  project = var.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.terraform_gke.email}"
}

resource "google_project_iam_member" "gke_compute_admin" {
  project = var.project_id
  role    = "roles/compute.admin"
  member  = "serviceAccount:${google_service_account.terraform_gke.email}"
}

resource "google_project_iam_member" "gke_sa_user" {
  project = var.project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.terraform_gke.email}"
}

# GKE SA needs read/write access to the state bucket.
resource "google_storage_bucket_iam_member" "gke_state_access" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.terraform_gke.email}"
}

# ---------- IAM: GCS Service Account ----------

resource "google_storage_bucket_iam_member" "gcs_state_admin" {
  bucket = google_storage_bucket.terraform_state.name
  role   = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.terraform_gcs.email}"
}

# ---------- WIF → Service Account Impersonation ----------
# The WIF pool and provider are managed manually in the GCP console.
# var.wif_pool_name is the pool resource name, e.g.:
#   projects/PROJECT_NUMBER/locations/global/workloadIdentityPools/POOL_ID

resource "google_service_account_iam_member" "wif_gke" {
  service_account_id = google_service_account.terraform_gke.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${var.wif_pool_name}/attribute.repository/${var.github_repo}"
}

resource "google_service_account_iam_member" "wif_gcs" {
  service_account_id = google_service_account.terraform_gcs.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${var.wif_pool_name}/attribute.repository/${var.github_repo}"
}
