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

# ---------- Workload Identity Federation ----------

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-actions"
  display_name              = "GitHub Actions"
  description               = "Identity pool for GitHub Actions OIDC"

  depends_on = [google_project_service.required_apis]
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"
  display_name                       = "GitHub OIDC"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
  }

  attribute_condition = "assertion.repository == \"${var.github_repo}\""

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# ---------- WIF → Service Account Impersonation ----------

resource "google_service_account_iam_member" "wif_gke" {
  service_account_id = google_service_account.terraform_gke.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}

resource "google_service_account_iam_member" "wif_gcs" {
  service_account_id = google_service_account.terraform_gcs.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github.name}/attribute.repository/${var.github_repo}"
}
