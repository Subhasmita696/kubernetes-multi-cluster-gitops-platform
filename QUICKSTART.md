# 🚀 Quick Start Guide - 5 Minutes to Your GitOps Platform!

## 📋 What You'll Get
After following this guide, you'll have:
- ✅ A Kubernetes cluster on AWS (EKS)
- ✅ ArgoCD managing your deployments
- ✅ Automated CI/CD pipeline
- ✅ A running NGINX application

---

## 🎯 Step 1: Fork This Repository

1. Click the **"Fork"** button at the top right of this page
2. Clone YOUR forked repository:
```bash
git clone https://github.com/YOUR-USERNAME/kubernetes-multi-cluster-gitops-platform.git
cd kubernetes-multi-cluster-gitops-platform
```

---

## ⚙️ Step 2: Configure AWS Credentials

```bash
# Install AWS CLI if you don't have it
# macOS:
brew install awscli

# Linux:
sudo apt-get install awscli

# Configure your AWS credentials
aws configure
# Enter your:
# - AWS Access Key ID
# - AWS Secret Access Key  
# - Default region: eu-north-1 (or your preferred region)
```

---

## 🏗️ Step 3: Customize Terraform Configuration

1. Copy the example configuration:
```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

2. Edit `terraform.tfvars` with your values:
```bash
# Open in your editor
nano terraform.tfvars  # or use: vim, code, etc.
```

3. **IMPORTANT**: Replace these values:
   - `subnet_ids` - Your VPC subnet IDs (find in AWS Console → VPC)
   - `cluster_name` - Give your cluster a unique name
   - `aws_region` - Your preferred AWS region

> 💡 **Don't have subnets?** See [CREATE_VPC.md](./docs/CREATE_VPC.md)

---

## 🚀 Step 4: Deploy Infrastructure

```bash
# Initialize Terraform
terraform init

# See what will be created
terraform plan

# Create your cluster (takes ~15 minutes)
terraform apply
# Type 'yes' when prompted
```

☕ **Grab a coffee!** EKS cluster creation takes 10-15 minutes.

---

## 🔧 Step 5: Configure kubectl

```bash
# Configure kubectl to connect to your cluster
aws eks update-kubeconfig --region eu-north-1 --name gitops-cluster

# Verify connection
kubectl get nodes
# You should see 2 nodes running!
```

---

## 🎨 Step 6: Install ArgoCD

```bash
# Create ArgoCD namespace
kubectl create namespace argocd

# Install ArgoCD
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Wait for ArgoCD to be ready (1-2 minutes)
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
```

---

## 🔑 Step 7: Access ArgoCD UI

```bash
# Get ArgoCD admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
# Copy this password!

# Access ArgoCD UI in another terminal
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Open browser: https://localhost:8080
# Username: admin
# Password: (the password you copied above)
```

---

## 📱 Step 8: Update Application Repository URL

**CRITICAL**: Update the ArgoCD application to point to YOUR repository:

```bash
# Edit the application.yaml file
nano argocd/application.yaml
```

Change this line:
```yaml
repoURL: https://github.com/Subhasmita696/kubernetes-multi-cluster-gitops-platform
```

To YOUR repository:
```yaml
repoURL: https://github.com/YOUR-USERNAME/kubernetes-multi-cluster-gitops-platform
```

Save and commit:
```bash
git add argocd/application.yaml
git commit -m "Update repo URL to my fork"
git push
```

---

## 🎯 Step 9: Deploy Your First Application

```bash
# Apply the ArgoCD application
kubectl apply -f argocd/application.yaml

# Watch it deploy!
kubectl get pods -n default --watch
```

In ArgoCD UI, you'll see your application syncing! 🎉

---

## 🌐 Step 10: Access Your Application

```bash
# Get the load balancer URL
kubectl get svc nginx-service -n default

# Look for the EXTERNAL-IP (takes 2-3 minutes to appear)
# Visit http://EXTERNAL-IP in your browser
```

---

## 🎊 Congratulations!

You now have a fully functional GitOps platform! 

### What Just Happened?

1. ✅ Created Kubernetes cluster on AWS
2. ✅ Installed ArgoCD for GitOps
3. ✅ Deployed NGINX application
4. ✅ Set up automated deployment pipeline

### Next Steps

- 📖 Read [CUSTOMIZE.md](./docs/CUSTOMIZE.md) to add your own applications
- 🔒 Check [SECURITY.md](./docs/SECURITY.md) for production hardening
- 📊 Add monitoring with [MONITORING.md](./docs/MONITORING.md)

---

## 🆘 Troubleshooting

### Terraform fails with "InvalidSubnet.NotFound"
👉 You need to create a VPC first. See [CREATE_VPC.md](./docs/CREATE_VPC.md)

### ArgoCD shows "ComparisonError"
👉 Make sure you updated the `repoURL` in Step 8 to YOUR repository

### Can't access NGINX
👉 Wait 2-3 minutes for the LoadBalancer to provision
👉 Run: `kubectl get svc nginx-service` and check EXTERNAL-IP

### Need help?
👉 Open an issue: https://github.com/Subhasmita696/kubernetes-multi-cluster-gitops-platform/issues

---

## 🧹 Clean Up (When Done Testing)

```bash
# Delete Kubernetes resources
kubectl delete -f argocd/application.yaml
kubectl delete namespace argocd

# Destroy infrastructure
cd terraform
terraform destroy
# Type 'yes' when prompted
```

**This will delete everything and stop AWS charges!** ⚠️
