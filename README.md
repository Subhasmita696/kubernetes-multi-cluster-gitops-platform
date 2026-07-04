# 🚀 Kubernetes Multi-Cluster GitOps Platform

> **Ready-to-use template for deploying applications to Kubernetes with GitOps!**  
> Just fork, customize, and deploy. Perfect for learning or production use.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.31-blue.svg)](https://kubernetes.io/)
[![ArgoCD](https://img.shields.io/badge/ArgoCD-v1beta1-green.svg)](https://argo-cd.readthedocs.io/)
[![Terraform](https://img.shields.io/badge/Terraform-1.9+-purple.svg)](https://www.terraform.io/)

---

## 📖 **How to Use This Template**

### 🎯 For Beginners

1. **Fork this repository** - Click the "Fork" button above
2. **Read [QUICKSTART.md](QUICKSTART.md)** - Step-by-step guide (takes ~20 minutes)
3. **Run the automated setup script**:
   ```bash
   git clone https://github.com/YOUR-USERNAME/kubernetes-multi-cluster-gitops-platform.git
   cd kubernetes-multi-cluster-gitops-platform
   ./setup.sh
   ```
4. **Done!** You now have a running Kubernetes cluster with GitOps

###📁 Project Structure

```
.
├── 📘 QUICKSTART.md          # Start here! 5-minute setup guide
├── 📘 setup.sh               # Automated installation script
├── 📁 .github/
│   └── workflows/
│       └── ci-cd.yaml        # GitHub Actions CI/CD pipeline
├── 📁 argocd/
│   ├── application.yaml      # ArgoCD app definition (👈 UPDATE REPO URL HERE)
│   └── apps/
│       └── nginx/
│           ├── deployment.yaml    # K8s deployment (👈 CUSTOMIZE THIS)
│           ├── service.yaml       # K8s service (👈 CUSTOMIZE THIS)
│           ├── hpa.yaml          # Auto-scaling config
│           └── helm-charts/      # Helm chart templates
├── 📁 terraform/
│   ├── eks.tf                     # EKS cluster configuration
│   └── terraform.tfvars.example   # Config template (👈 COPY & CUSTOMIZE)
├── 📁 docs/
│   ├── CUSTOMIZE.md          # How to add your apps
│   ├── FAQ.md                # Frequently asked questions
│   └── CREATE_VPC.md         # VPC creation guide
├── Dockerfile                # Custom NGINX container (👈 REPLACE WITH YOUR APP)
└── nginx.conf                # NGINX configuration (👈 CUSTOMIZE IF NEEDED)
```

### 🎯 Files You'll Need to Customize

| File | What to Change | Why |
|------|---------------|-----|
| `argocd/application.yaml` | Repository URL | Point to YOUR fork |
| `terraform/terraform.tfvars` | AWS region, subnet IDs | Your AWS settings |
| `argocd/apps/nginx/deployment.yaml` | Container image, app name | Your application |
| `Dockerfile` | Your app code | Replace NGINX with your app |

---

##  🚀 Quick Commands

```bash
# Clone your fork
git clone https://github.com/YOUR-USERNAME/kubernetes-multi-cluster-gitops-platform.git
cd kubernetes-multi-cluster-gitops-platform

# Option 1: Automated Setup (Recommended for beginners)
./setup.sh

# Option 2: Manual Setup (For learning)
# See QUICKSTART.md for detailed steps
```

---

## 📚 **Documentation**

| Document | Description |
|----------|-------------|
| **[QUICKSTART.md](QUICKSTART.md)** | 5-minute guide to get started |
| **[docs/CUSTOMIZE.md](docs/CUSTOMIZE.md)** | Add your own applications |
| **[docs/FAQ.md](docs/FAQ.md)** | Common questions & answers |
| **[docs/CREATE_VPC.md](docs/CREATE_VPC.md)** | Create AWS VPC from scratch |
| **[CONTRIBUTING.md](CONTRIBUTING.md)** | How to contribute |

---

A production-ready GitOps platform built using Kubernetes and ArgoCD to manage applications across multiple clusters (dev, staging, production).

## 🔧 Tech Stack

* **Kubernetes 1.31** (AWS EKS)
* **ArgoCD v1beta1** (GitOps continuous delivery)
* **Terraform 1.9+** with AWS Provider 5.80+ (Infrastructure as Code)
* **Helm 3** (Application templating)
* **GitHub Actions v4** (CI/CD pipelines)
* **NGINX 1.27-alpine** (Application runtime)
* **Docker Buildx v6** (Multi-architecture image builds)

## 🌍 Key Features

* ✅ Multi-cluster deployment strategy
* ✅ Automated GitOps-based delivery with self-healing
* ✅ Environment promotion (dev → staging → prod)
* ✅ Infrastructure provisioning using Terraform with full IAM roles
* ✅ Production-grade security contexts and resource limits
* ✅ Multi-architecture support (amd64/arm64)
* ✅ Health checks and probes
* ✅ Vulnerability scanning with Trivy
* ✅ Rolling updates with zero downtime

## ⚡ How It Works

1. Developer pushes code to GitHub
2. GitHub Actions builds multi-arch Docker images
3. Images are pushed to GitHub Container Registry
4. Manifests are updated with new image tags
5. ArgoCD detects changes and syncs to Kubernetes clusters
6. Applications are deployed with automated health checks

## 📊 Architecture

```
┌─────────────┐      ┌──────────────┐      ┌─────────────┐
│   GitHub    │─────▶│ GitHub       │─────▶│   GHCR      │
│ Repository  │      │ Actions      │      │  Registry   │
└─────────────┘      └──────────────┘      └─────────────┘
                            │                      │
                            ▼                      ▼
                     ┌──────────────┐      ┌─────────────┐
                     │  Update      │      │  ArgoCD     │
                     │  Manifests   │─────▶│  Sync       │
                     └──────────────┘      └─────────────┘
                                                  │
                            ┌─────────────────────┼─────────────────────┐
                            ▼                     ▼                     ▼
                     ┌────────────┐       ┌────────────┐       ┌────────────┐
                     │    Dev     │       │  Staging   │       │    Prod    │
                     │  Cluster   │       │  Cluster   │       │  Cluster   │
                     └────────────┘       └────────────┘       └────────────┘
```

## 🚀 Quick Start

### Prerequisites
- AWS CLI configured
- Terraform 1.9+
- kubectl
- Helm 3+
- ArgoCD CLI

### 1. Provision Infrastructure
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 2. Install ArgoCD
```bash
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

### 3. Deploy Applications
```bash
kubectl apply -f argocd/application.yaml
```

### 4. Access ArgoCD UI
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

## 📁 Project Structure

```
.
├── .github/
│   └── workflows/
│       └── ci-cd.yaml          # Modern CI/CD pipeline
├── argocd/
│   ├── application.yaml         # ArgoCD application definition
│   └── apps/
│       └── nginx/
│           ├── deployment.yaml  # Kubernetes deployment
│           ├── service.yaml     # Kubernetes service
│           └── helm-charts/
│  🆘 Need Help?

### Common Issues

| Problem | Solution |
|---------|----------|
| AWS credentials error | Run `aws configure` |
| Can't find subnet IDs | See [CREATE_VPC.md](docs/CREATE_VPC.md) |
| ArgoCD ComparisonError | Update `repoURL` in `argocd/application.yaml` |
| Pods stuck pending | Wait 2-3 minutes for nodes to be ready |

📖 **More help:** See [docs/FAQ.md](docs/FAQ.md) for detailed troubleshooting

### Get Support

1. 📖 Read [FAQ.md](docs/FAQ.md)
2. 🔍 Search [existing issues](https://github.com/Subhasmita696/kubernetes-multi-cluster-gitops-platform/issues)
3. 🆕 [Open a new issue](https://github.com/Subhasmita696/kubernetes-multi-cluster-gitops-platform/issues/new)

---

## 💰 Cost Estimate

**Small Development Setup:** ~$70-100/month
- EKS Control Plane: $72/month
- 2x t3.medium nodes: ~$60/month  
- Load Balancer: ~$16/month
- NAT Gateway: ~$32/month (optional)

💡 **Save money:** Use `t3.small` instances and delete when not in use: `terraform destroy`

---

## 🧹 Clean Up

**Important:** Delete everything when done to avoid AWS charges!

```bash
# Delete Kubernetes resources
kubectl delete -f argocd/application.yaml
kubectl delete namespace argocd

# Destroy infrastructure
cd terraform
terraform destroy
# Type 'yes' to confirm
```

---

## 🎓 What You'll Learn

By using this template, you'll gain hands-on experience with:

- ✅ Kubernetes deployments and services
- ✅ GitOps principles with ArgoCD
- ✅ Infrastructure as Code with Terraform
- ✅ AWS EKS cluster management
- ✅ CI/CD pipelines with GitHub Actions
- ✅ Container security best practices
- ✅ Helm charts and templating
- ✅ Multi-environment deployment strategies

---

## 🔗 Related Projects & Resources

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitOps Guide](https://www.gitops.tech/)

---

## 📝 License

MIT License - feel free to use this for personal or commercial projects!

---

## 🙏 Contributing

Contributions are welcome! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## ⭐ Show Your Support

If this helped you, please:
- ⭐ Star this repository
- 🍴 Fork it and build something awesome
- 📢 Share it with others

---

## 👨‍💻 Author

**Subhasmita Das**  
GitHub: [@Subhasmita696](https://github.com/Subhasmita696)

---

## 📅 Last Updated

July 2026 - Using latest stable versions of all components
│                       ├── _helpers.tpl
│                       ├── deployment.yaml
│                       └── service.yaml
└── terraform/
    └── eks.tf                   # EKS cluster + IAM configuration
```

## 🔒 Security Features

* Non-root container execution
* Dropped capabilities (ALL)
* Resource limits enforced
* Automated vulnerability scanning (Trivy)
* Security context policies
* Least privilege IAM roles

## 🔮 Future Improvements

* [ ] Monitoring stack (Prometheus + Grafana)
* [ ] Canary / Blue-Green deployments
* [ ] Policy enforcement (OPA/Gatekeeper)
* [ ] Multi-region failover
* [ ] Service mesh (Istio)
* [ ] Cost optimization (Karpenter)

## 📌 Why This Project

This project demonstrates modern DevOps and SRE practices including:
- GitOps workflows with ArgoCD
- Multi-cluster management
- Infrastructure as Code with Terraform
- Container security best practices
- CI/CD automation
- Production-grade Kubernetes deployments

## 👨‍💻 Author

**Subhasmita Das**  
GitHub: [@Subhasmita696](https://github.com/Subhasmita696)
