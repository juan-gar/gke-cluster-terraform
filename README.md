<<<<<<< HEAD
# gke-cluster-terraform
=======
# ------------------------------------------------------------------
# README.md
# ------------------------------------------------------------------
# # Automated GKE Cluster Provisioning with Terraform
#
# This Terraform project provisions a Google Kubernetes Engine (GKE) cluster
# with a focus on security and best practices.
#
# ## Features
#
# - **Custom Node Pool**: Separates the control plane from the workloads.
# - **Workload Identity**: Provides secure, keyless access for pods to Google Cloud services.
# - **Network Policies**: Enables network segmentation for enhanced security.
# - **Configurable**: Easily change the region, machine type, and node count via variables.
#
# ## How to Use
#
# ### Prerequisites
#
# 1. Install Terraform (https://learn.hashicorp.com/tutorials/terraform/install-cli)
# 2. Configure Google Cloud authentication (e.g., `gcloud auth application-default login`)
#
# ### Steps
#
# 1.  **Initialize Terraform**:
#     ```sh
#     terraform init
#     ```
#
# 2.  **Review the Plan**:
#     Replace `your-gcp-project-id` with your actual Google Cloud Project ID.
#     ```sh
#     terraform plan -var="project_id=your-gcp-project-id"
#     ```
#
# 3.  **Apply the Configuration**:
#     This will create the resources in your Google Cloud account.
#     ```sh
#     terraform apply -var="project_id=your-gcp-project-id"
#     ```
#
# 4. **Destroy the Resources**:
#    When you are finished, you can destroy the created resources to avoid costs.
#    ```sh
#    terraform destroy -var="project_id=your-gcp-project-id"
#    ```
>>>>>>> e3fb384 (First commit)
