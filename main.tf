
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
    prefix = "terraform/state"
  }
}

# Configure the Google Cloud provider to manage resources.
provider "google" {
  project = var.project_id
  region  = var.region
}

# Create the GKE cluster resource.
resource "google_container_cluster" "primary" {
  # Naming the cluster based on the project ID for clarity.
  name     = "${var.project_id}-gke-cluster"
  location = var.region

  deletion_protection = false

  # We can't create a cluster with no node pool defined, but we want to use
  # a separately managed node pool. This approach creates a minimal default
  # node pool and immediately removes it, which is a common best practice.
  remove_default_node_pool = true
  initial_node_count       = 1

  # Enable network policies to control traffic flow between pods.
  # This is a critical security feature.
  network_policy {
    enabled = true
  }

  # Enable Workload Identity, the recommended way for GKE applications
  # to securely access Google Cloud services without service account keys.
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
}

# Create a custom node pool for our workloads.
# Managing node pools separately from the cluster provides more flexibility.
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-workload-pool"
  location   = var.region
  cluster    = google_container_cluster.primary.name
  node_count = var.node_count

  node_config {
    # Using preemptible VMs can significantly reduce costs for fault-tolerant workloads.
    preemptible  = true
    machine_type = var.machine_type

    # Set disk type and size to fit quota
    disk_type    = "pd-standard"
    disk_size_gb = 50

    # Enable Workload Identity for the node pool.
    # This allows pods in this node pool to use the GKE Workload Identity feature.
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Define the OAuth scopes for the node service account.
    # 'cloud-platform' provides full access to all Cloud APIs.
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}



