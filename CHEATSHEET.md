# ⚡ Quick Reference Cheat Sheet

## 🚀 **Getting Started** (Copy & Paste)

```bash
# 1. Fork & Clone
git clone https://github.com/YOUR-USERNAME/kubernetes-multi-cluster-gitops-platform.git
cd kubernetes-multi-cluster-gitops-platform

# 2. Automated Setup
./setup.sh

# Or Manual Setup - Follow QUICKSTART.md
```

---

## 📝 **Essential Commands**

### Cluster Management
```bash
# Get nodes
kubectl get nodes

# Get all pods
kubectl get pods -A

# Get cluster info
kubectl cluster-info

# Update kubeconfig
aws eks update-kubeconfig --region REGION --name CLUSTER-NAME
```

### ArgoCD
```bash
# Install ArgoCD
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Get password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Port forward to UI
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Deploy app
kubectl apply -f argocd/application.yaml

# Watch sync
kubectl get applications -n argocd --watch
```

### Application Management
```bash
# Get services (to see LoadBalancer IP)
kubectl get svc

# Get pods
kubectl get pods

# Check pod logs
kubectl logs POD-NAME

# Describe pod (for troubleshooting)
kubectl describe pod POD-NAME

# Delete and recreate pod
kubectl delete pod POD-NAME
```

### Terraform
```bash
# Initialize
cd terraform
terraform init

# Plan changes
terraform plan

# Apply (create resources)
terraform apply

# Destroy (delete everything)
terraform destroy

# Show current state
terraform show
```

---

## 🔧 **Files You MUST Customize**

### 1. Repository URL ⚠️ CRITICAL
**File:** `argocd/application.yaml`
```yaml
repoURL: https://github.com/YOUR-USERNAME/YOUR-REPO
```

### 2. AWS Configuration
**File:** `terraform/terraform.tfvars` (copy from .example)
```hcl
aws_region = "us-east-1"
cluster_name = "my-cluster"
subnet_ids = ["subnet-xxx", "subnet-yyy"]
```

### 3. Your Application
**File:** `argocd/apps/nginx/deployment.yaml`
```yaml
image: your-image:tag
```

---

## 🔍 **Troubleshooting Quick Fixes**

### Problem: AWS Credentials Error
```bash
aws configure
# Enter: Access Key ID, Secret Key, Region
```

### Problem: Can't Find Subnets
```bash
# List VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock]' --output table

# List subnets
aws ec2 describe-subnets --query 'Subnets[*].[SubnetId,VpcId,CidrBlock]' --output table
```

### Problem: Pods Not Starting
```bash
# Check pod events
kubectl describe pod POD-NAME

# Check logs
kubectl logs POD-NAME

# Check nodes
kubectl get nodes
```

### Problem: ArgoCD Sync Failing
```bash
# Check application status
kubectl get application -n argocd

# Describe application
kubectl describe application APP-NAME -n argocd

# Check ArgoCD logs
kubectl logs -n argocd deployment/argocd-server
```

---

## 📊 **Common Modifications**

### Change Number of Replicas
**File:** `argocd/apps/nginx/deployment.yaml`
```yaml
spec:
  replicas: 3  # Change from 2 to 3
```

### Change Resource Limits
**File:** `argocd/apps/nginx/deployment.yaml`
```yaml
resources:
  limits:
    memory: "256Mi"  # Increase from 128Mi
    cpu: "500m"      # Increase from 200m
```

### Change Service Type
**File:** `argocd/apps/nginx/service.yaml`
```yaml
spec:
  type: ClusterIP  # Instead of LoadBalancer (internal only)
```

### Change Cluster Size
**File:** `terraform/terraform.tfvars`
```hcl
node_instance_types = ["t3.small"]  # Smaller instances
node_desired_size   = 1             # Fewer nodes
```

---

## 💰 **Cost Control**

```bash
# See what will be destroyed
terraform plan -destroy

# Destroy everything (stops charges)
terraform destroy

# For testing: Use spot instances (advanced)
# Edit eks.tf and add:
capacity_type = "SPOT"
```

---

## 🎯 **Useful kubectl Shortcuts**

```bash
# Create alias
alias k=kubectl

# Get everything
k get all

# Get with wide output
k get pods -o wide

# Get in JSON
k get pod POD-NAME -o json

# Edit resource
k edit deployment DEPLOYMENT-NAME

# Delete resource
k delete deployment DEPLOYMENT-NAME

# Force delete pod
k delete pod POD-NAME --force --grace-period=0
```

---

## 📁 **Directory Structure (Quick Reference)**

```
kubernetes-multi-cluster-gitops-platform/
├── 📘 HOW_TO_USE.md         ← YOU ARE HERE!
├── 📘 QUICKSTART.md         ← Detailed setup guide
├── 📘 setup.sh              ← Automated installer
├── 📁 argocd/
│   ├── application.yaml     ← UPDATE REPO URL HERE!
│   └── apps/nginx/
│       ├── deployment.yaml  ← YOUR APP CONFIG
│       └── service.yaml     ← NETWORK CONFIG
├── 📁 terraform/
│   ├── eks.tf              ← Cluster definition
│   └── terraform.tfvars    ← YOUR AWS SETTINGS
├── 📁 docs/
│   ├── CUSTOMIZE.md        ← Add your apps
│   ├── FAQ.md              ← Common questions
│   └── CREATE_VPC.md       ← VPC setup
└── Dockerfile              ← YOUR APP IMAGE
```

---

## 🔗 **Helpful Links**

| Resource | URL |
|----------|-----|
| Kubernetes Docs | https://kubernetes.io/docs/ |
| ArgoCD Docs | https://argo-cd.readthedocs.io/ |
| Terraform Registry | https://registry.terraform.io/ |
| AWS EKS Docs | https://docs.aws.amazon.com/eks/ |

---

## 🆘 **Get Help**

1. Check [FAQ.md](docs/FAQ.md)
2. Search [GitHub Issues](https://github.com/Subhasmita696/kubernetes-multi-cluster-gitops-platform/issues)
3. Open new issue with error details

---

## ✅ **Pre-Flight Checklist**

Before deploying to production:

- [ ] Changed default passwords
- [ ] Updated repository URL
- [ ] Configured proper resource limits
- [ ] Set up monitoring (Prometheus/Grafana)
- [ ] Configured backups
- [ ] Reviewed security settings
- [ ] Tested in dev environment first
- [ ] Set up alerts
- [ ] Documented custom changes
- [ ] Created disaster recovery plan

---

**💡 Tip:** Bookmark this page for quick reference!
