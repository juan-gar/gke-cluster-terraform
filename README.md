# 🚀 Automated GKE Cluster Provisioning with Terraform

[![Terraform](https://img.shields.io/badge/Terraform-623CE4?style=for-the-badge&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Google Cloud](https://img.shields.io/badge/Google%20Cloud-4285F4?style=for-the-badge&logo=google-cloud&logoColor=white)](https://cloud.google.com/)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)](https://kubernetes.io/)

> A production-ready Terraform configuration for provisioning secure Google Kubernetes Engine (GKE) clusters with enterprise-grade security features and best practices.

## ✨ Features

🔐 **Security First**
- **Custom Node Pool**: Complete separation between control plane and workloads
- **Workload Identity**: Keyless, secure access for pods to Google Cloud services
- **Network Policies**: Advanced network segmentation for enhanced security

⚙️ **Flexible Configuration**
- Easily customizable region, machine type, and node count
- Variable-driven configuration for different environments
- Production-ready defaults with override capabilities

🏗️ **Best Practices Built-in**
- Infrastructure as Code (IaC) approach
- Modular and maintainable Terraform structure
- Cloud-native security patterns

## 🛠️ Prerequisites

Before you begin, ensure you have the following installed and configured:

| Tool | Purpose | Installation Link |
|------|---------|------------------|
| **Terraform** | Infrastructure provisioning | [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) |
| **Google Cloud SDK** | GCP authentication & CLI | [Install gcloud](https://cloud.google.com/sdk/docs/install) |
| **kubectl** | Kubernetes cluster management | [Install kubectl](https://kubernetes.io/docs/tasks/tools/) |

### 🔑 Authentication Setup

Configure your Google Cloud authentication:

```bash
gcloud auth application-default login
```

## 🚀 Quick Start

### 1. Initialize Terraform

```bash
terraform init
```

### 2. Review the Execution Plan

Replace `your-gcp-project-id` with your actual Google Cloud Project ID:

```bash
terraform plan -var="project_id=your-gcp-project-id"
```

### 3. Deploy the Infrastructure

```bash
terraform apply -var="project_id=your-gcp-project-id"
```

> 💡 **Tip**: Use `-auto-approve` flag to skip the confirmation prompt for automated deployments.

### 4. Connect to Your Cluster

After successful deployment, configure kubectl:

```bash
gcloud container clusters get-credentials <cluster-name> --region <region> --project <project-id>
```

## 🔧 Configuration

### Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `project_id` | Google Cloud Project ID | - | ✅ |
| `region` | GCP region for resources | `us-central1` | ❌ |
| `node_count` | Number of nodes per zone | `1` | ❌ |
| `machine_type` | GCE machine type | `e2-medium` | ❌ |

### Example Configuration

Create a `terraform.tfvars` file:

```hcl
project_id   = "my-gcp-project"
region       = "us-west1"
node_count   = 3
machine_type = "e2-standard-4"
```

## 📁 Project Structure

```
├── main.tf              # Primary Terraform configuration
├── variables.tf         # Variable definitions
├── outputs.tf          # Output values
├── terraform.tfvars    # Variable values (create this)
└── README.md          # This file
```

## 🔐 Security Features

### Workload Identity
Enables secure access to Google Cloud services without storing service account keys:

```yaml
# Example pod configuration
apiVersion: v1
kind: Pod
metadata:
  annotations:
    iam.gke.io/gcp-service-account: my-service-account@project.iam.gserviceaccount.com
```

### Network Policies
Implement microsegmentation with Kubernetes Network Policies:

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
```

## 🧹 Cleanup

To avoid ongoing charges, destroy the resources when finished:

```bash
terraform destroy -var="project_id=your-gcp-project-id"
```

> ⚠️ **Warning**: This will permanently delete all resources created by this Terraform configuration.

## 📊 Cost Optimization

- Use **Spot VMs** for non-critical workloads
- Enable **Cluster Autoscaling** for dynamic scaling
- Configure **Horizontal Pod Autoscaling** for applications
- Monitor usage with **Google Cloud Billing**

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- 📖 [Terraform GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- 🏗️ [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- 💬 [Community Support](https://github.com/your-username/your-repo/issues)

---

<div align="center">
  <strong>Built with ❤️ using Terraform and Google Cloud</strong>
</div>