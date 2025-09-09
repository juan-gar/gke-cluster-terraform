# GitHub Actions Setup for Workload Identity

This document explains how to set up GitHub Actions with Workload Identity to deploy your GKE infrastructure.

## Prerequisites

1. A Google Cloud Project with billing enabled
2. A GitHub repository for this Terraform code
3. The following APIs enabled in your GCP project:
   - Identity and Access Management (IAM) API
   - IAM Service Account Credentials API
   - Kubernetes Engine API
   - Compute Engine API

## Setup Steps

### 1. Create a Service Account

```bash
gcloud iam service-accounts create terraform-deploy \
    --description="Service account for Terraform deployments" \
    --display-name="Terraform Deploy"
```

### 2. Grant Necessary IAM Roles

```bash
PROJECT_ID="your-project-id"  # Replace with your actual project ID

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform-deploy@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/container.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform-deploy@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/compute.admin"

gcloud projects add-iam-policy-binding $PROJECT_ID \
    --member="serviceAccount:terraform-deploy@$PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/iam.serviceAccountUser"
```

### 3. Create Workload Identity Pool

```bash
gcloud iam workload-identity-pools create "github-actions" \
    --project="$PROJECT_ID" \
    --location="global" \
    --display-name="GitHub Actions Pool"
```

### 4. Create Workload Identity Provider

```bash
REPO="your-github-username/your-repo-name"  # Replace with your GitHub repo

gcloud iam workload-identity-pools providers create-oidc "github-actions-provider" \
    --project="$PROJECT_ID" \
    --location="global" \
    --workload-identity-pool="github-actions" \
    --display-name="GitHub Actions Provider" \
    --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
    --issuer-uri="https://token.actions.githubusercontent.com"
```

### 5. Allow GitHub Actions to Impersonate the Service Account

```bash
gcloud iam service-accounts add-iam-policy-binding \
    "terraform-deploy@$PROJECT_ID.iam.gserviceaccount.com" \
    --project="$PROJECT_ID" \
    --role="roles/iam.workloadIdentityUser" \
    --member="principalSet://iam.googleapis.com/projects/$(gcloud projects describe $PROJECT_ID --format='value(projectNumber)')/locations/global/workloadIdentityPools/github-actions/attribute.repository/$REPO"
```

### 6. Get the Workload Identity Provider Resource Name

```bash
gcloud iam workload-identity-pools providers describe "github-actions-provider" \
    --project="$PROJECT_ID" \
    --location="global" \
    --workload-identity-pool="github-actions" \
    --format="value(name)"
```

This will output something like: `projects/123456789/locations/global/workloadIdentityPools/github-actions/providers/github-actions-provider`

### 7. Configure GitHub Repository Secrets

In your GitHub repository, go to Settings → Secrets and variables → Actions, and add these repository secrets:

- `WIF_PROVIDER`: The full resource name from step 6
- `WIF_SERVICE_ACCOUNT`: `terraform-deploy@YOUR_PROJECT_ID.iam.gserviceaccount.com`

### 8. Update Terraform Variables (Optional)

If you want to override the default project ID in your Terraform configuration, you can either:

- Update the default value in `variables.tf`
- Add a `terraform.tfvars` file to your repository (not recommended for production)
- Set environment variables in the GitHub workflow

## Environment Protection (Recommended)

For production deployments, consider setting up environment protection rules:

1. Go to your GitHub repository Settings → Environments
2. Create a new environment called "production"
3. Add protection rules such as:
   - Required reviewers
   - Wait timer
   - Deployment branches (restrict to main branch)

## Workflow Behavior

- **On Pull Requests**: Runs `terraform plan` and comments the plan output on the PR
- **On Push to Main**: Runs `terraform plan` followed by `terraform apply` to deploy changes
- **Format Check**: Ensures Terraform code is properly formatted
- **Validation**: Validates Terraform configuration syntax

## Security Considerations

- The service account has broad permissions for GKE and Compute Engine management
- Consider using more granular IAM roles for production environments
- The workflow only runs on pushes to main and pull requests targeting main
- Workload Identity eliminates the need for service account keys

## Troubleshooting

If you encounter authentication issues:

1. Verify the workload identity pool and provider are created correctly
2. Check that the service account has the necessary IAM bindings
3. Ensure the GitHub repository secrets are set correctly
4. Verify the repository name format in the IAM binding (should be "owner/repo-name")