terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }

  # Bootstrap uses local state because it creates the remote state bucket.
  # Run this locally with `gcloud auth application-default login` first.
}

provider "google" {
  project = var.project_id
  region  = var.region
}

data "google_project" "current" {}

# ---------- Enable required APIs ----------

resource "google_project_service" "required_apis" {
  for_each = toset([
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "sts.googleapis.com",
    "container.googleapis.com",
    "compute.googleapis.com",
    "cloudresourcemanager.googleapis.com",
  ])

  service            = each.value
  disable_on_destroy = false
}

# ---------- GCS state bucket ----------

resource "google_storage_bucket" "terraform_state" {
  name     = "${var.project_id}-terraform-state"
  location = "US"

  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    condition {
      num_newer_versions = 3
    }
    action {
      type = "Delete"
    }
  }

  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 30
    }
    action {
      type = "Delete"
    }
  }
}
