# ❓ Frequently Asked Questions (FAQ)

## 🎯 General Questions

### Q: What is this project?
**A:** A ready-to-use template for deploying applications to Kubernetes using GitOps principles with ArgoCD. Just copy, customize, and deploy!

### Q: Do I need to know Kubernetes?
**A:** Basic knowledge helps, but not required! Follow the [QUICKSTART.md](QUICKSTART.md) step by step.

### Q: How much will this cost on AWS?
**A:** Approximately $70-100/month for a small cluster:
- EKS Control Plane: ~$72/month
- 2 x t3.medium nodes: ~$60/month
- Load Balancer: ~$16/month
- NAT Gateway: ~$32/month (optional)

💡 Use `t3.small` instances for testing to reduce costs!

### Q: Can I use this with other cloud providers?
**A:** The GitOps concepts work everywhere, but the Terraform code is AWS-specific. You'd need to modify `terraform/eks.tf` for:
- Google Cloud (GKE)
- Azure (AKS)
- On-premises Kubernetes

---

## 🔧 Setup Questions

### Q: I forked the repo, now what?
**A:** Follow these steps:
1. Clone YOUR fork: `git clone https://github.com/YOUR-USERNAME/kubernetes-multi-cluster-gitops-platform.git`
2. Follow [QUICKSTART.md](QUICKSTART.md)
3. Update the repository URLs to point to YOUR fork

### Q: What AWS permissions do I need?
**A:** You need IAM permissions to create:
- EKS clusters
- EC2 instances
- VPCs and networking
- IAM roles
- Load Balancers

💡 Use an IAM user with `AdministratorAccess` for testing (restrict for production!)

### Q: Can I run this locally?
**A:** You can run Kubernetes locally with:
- Minikube
- kind (Kubernetes in Docker)
- Docker Desktop

But the Terraform code creates AWS resources. For local testing, skip Terraform and install ArgoCD on your local cluster.

---

## 🐛 Common Errors

### Q: "Error: error configuring Terraform AWS Provider: no valid credential sources"
**A:** Your AWS credentials aren't configured.
```bash
aws configure
# Enter your Access Key ID and Secret Access Key
```

### Q: "Error: InvalidSubnet.NotFound"
**A:** The subnet IDs in your `terraform.tfvars` don't exist.
- Follow [CREATE_VPC.md](docs/CREATE_VPC.md) to create a VPC
- Or update `subnet_ids` with your existing subnet IDs

### Q: "Error: creating EKS Cluster: InvalidParameterException: role ARN invalid"
**A:** This shouldn't happen with the updated code. If it does:
```bash
cd terraform
terraform destroy
terraform apply
```

### Q: ArgoCD shows "ComparisonError: rpc error"
**A:** The repository URL is wrong. Update `argocd/application.yaml`:
```yaml
repoURL: https://github.com/YOUR-USERNAME/YOUR-REPO
```

### Q: Pods stuck in "Pending" state
**A:** Check if nodes are ready:
```bash
kubectl get nodes
kubectl describe pod POD-NAME
```
Common causes:
- Nodes not ready yet (wait 2-3 minutes)
- Insufficient resources (scale up nodes)
- Image pull errors (check image name)

### Q: Can't access ArgoCD UI
**A:** Make sure port-forward is running:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Then visit: https://localhost:8080 (note: HTTPS)

---

## 🔐 Security Questions

### Q: Is this production-ready?
**A:** It has production-grade configurations, but you should:
- ✅ Enable encryption at rest
- ✅ Set up VPN/bastion for cluster access
- ✅ Configure network policies
- ✅ Enable audit logging
- ✅ Set up monitoring and alerting
- ✅ Implement backup strategy

See [SECURITY.md](docs/SECURITY.md) for details.

### Q: How do I add secrets?
**A:** Several options:

**Option 1: Kubernetes Secrets**
```bash
kubectl create secret generic my-secret \
  --from-literal=password=mypassword
```

**Option 2: Sealed Secrets (recommended)**
```bash
# Install sealed-secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# Create sealed secret
echo -n mypassword | kubectl create secret generic my-secret \
  --dry-run=client --from-file=password=/dev/stdin -o yaml | \
  kubeseal -o yaml > sealed-secret.yaml
```

**Option 3: External Secrets Operator**
- Integrate with AWS Secrets Manager, HashiCorp Vault, etc.

### Q: The ArgoCD password is exposed!
**A:** Change it immediately:
```bash
# Login to ArgoCD
argocd login localhost:8080

# Update password
argocd account update-password

# Delete the initial secret
kubectl delete secret argocd-initial-admin-secret -n argocd
```

---

## 🚀 Deployment Questions

### Q: How do I deploy my own application?
**A:** See [CUSTOMIZE.md](docs/CUSTOMIZE.md) for detailed instructions!

Quick version:
1. Add your app manifests to `argocd/apps/my-app/`
2. Create an ArgoCD application YAML
3. Push to your repository
4. ArgoCD auto-deploys!

### Q: How do I update my application?
**A:** Just push changes to your repository!
```bash
# Edit your deployment
vim argocd/apps/nginx/deployment.yaml

# Commit and push
git add .
git commit -m "Update deployment"
git push

# ArgoCD syncs automatically!
```

### Q: Can I deploy multiple apps?
**A:** Yes! See "App-of-Apps" pattern in [CUSTOMIZE.md](docs/CUSTOMIZE.md)

### Q: How do I rollback?
**A:** 
**Option 1: Via ArgoCD UI**
- Open ArgoCD
- Click your app
- Click "History and Rollback"
- Select previous version

**Option 2: Via Git**
```bash
git revert HEAD
git push
```

---

## 🌍 Multi-Environment Questions

### Q: How do I set up dev/staging/prod?
**A:** See [CUSTOMIZE.md](docs/CUSTOMIZE.md) - Environment Setup section

Popular approaches:
- Separate clusters (recommended)
- Separate namespaces (cost-effective)
- Kustomize overlays (flexible)

### Q: How do I promote from dev to prod?
**A:** 
1. Test in dev environment
2. Update staging environment image tag
3. Test in staging
4. Update prod environment image tag
5. Monitor deployment

Or use tools like:
- ArgoCD Image Updater
- Flux
- Custom CI/CD pipeline

---

## 💰 Cost Questions

### Q: How can I reduce costs?
**A:** 
- Use smaller instance types: `t3.small` instead of `t3.medium`
- Reduce node count: `min_size = 1`
- Use Spot Instances (advanced)
- Disable NAT Gateway (less secure, use public subnets)
- Delete when not in use: `terraform destroy`

### Q: Will I be charged if I follow this guide?
**A:** YES! AWS EKS and EC2 instances cost money. Always run `terraform destroy` when done testing!

---

## 🛠️ Customization Questions

### Q: Can I use a different image instead of NGINX?
**A:** Absolutely! Edit `argocd/apps/nginx/deployment.yaml`:
```yaml
containers:
- name: my-app
  image: your-image:tag
```

### Q: How do I add a database?
**A:** Several options:
- Use AWS RDS (recommended for production)
- Deploy PostgreSQL/MySQL in Kubernetes
- Use managed services (ElastiCache, etc.)

### Q: Can I use Helm charts from other sources?
**A:** Yes! Update your ArgoCD application:
```yaml
source:
  repoURL: https://charts.bitnami.com/bitnami
  chart: postgresql
  targetRevision: 12.1.0
```

---

## 📊 Monitoring Questions

### Q: How do I monitor my cluster?
**A:** Install Prometheus and Grafana:
```bash
kubectl create namespace monitoring

# Install Prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack -n monitoring

# Access Grafana
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
# Default: admin / prom-operator
```

### Q: How do I check logs?
**A:**
```bash
# Pod logs
kubectl logs POD-NAME

# Follow logs
kubectl logs -f POD-NAME

# Previous crashed container
kubectl logs POD-NAME --previous
```

For centralized logging, consider:
- AWS CloudWatch
- ELK Stack
- Loki + Grafana

---

## 🆘 Still Need Help?

1. Check [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
2. Search existing [GitHub Issues](https://github.com/Subhasmita696/kubernetes-multi-cluster-gitops-platform/issues)
3. Open a new issue with:
   - What you tried
   - Error messages
   - Your configuration (remove secrets!)

---

## 📚 Learning Resources

- [Kubernetes Basics](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [GitOps Explained](https://www.gitops.tech/)
