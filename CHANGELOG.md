# Kubernetes Multi-Cluster GitOps Platform

## 🚦 Build Status

![CI/CD Pipeline](https://github.com/Subhasmita696/kubernetes-multi-cluster-gitops-platform/workflows/CI-CD%20Pipeline/badge.svg)

## 📊 Version Information

| Component | Version |
|-----------|---------|
| Kubernetes | 1.31 |
| ArgoCD | v1beta1 |
| Terraform | 1.9+ |
| AWS Provider | 5.80+ |
| NGINX | 1.27-alpine |
| Helm | 3.x |
| GitHub Actions | v4 |

## 🔄 Recent Upgrades

### Infrastructure
- ✅ Terraform upgraded to 1.9+ with AWS provider 5.80
- ✅ EKS cluster upgraded to Kubernetes 1.31
- ✅ Complete IAM roles and policies implementation
- ✅ Node groups with auto-scaling configuration

### Application
- ✅ NGINX upgraded to 1.27-alpine (production stable)
- ✅ Removed `latest` tag for better version control
- ✅ Added production-grade security contexts
- ✅ Implemented resource limits and requests
- ✅ Added liveness and readiness probes

### CI/CD
- ✅ GitHub Actions upgraded to v4
- ✅ Multi-architecture builds (amd64/arm64)
- ✅ Trivy security scanning integrated
- ✅ Automated manifest updates
- ✅ Proper workflow organization

### GitOps
- ✅ ArgoCD upgraded to v1beta1 API
- ✅ Enhanced sync policies with retry logic
- ✅ Added finalizers for proper cleanup
- ✅ Improved health check configurations

### Helm Charts
- ✅ Chart version bumped to 1.0.0
- ✅ Added comprehensive templates
- ✅ Implemented helper functions
- ✅ Production-ready default values

### Security
- ✅ Non-root container execution
- ✅ Dropped all capabilities
- ✅ Resource limits enforced
- ✅ Vulnerability scanning in CI
- ✅ Security headers in NGINX config

## 📈 What's New

- 🎯 **HPA Support**: Horizontal Pod Autoscaler for dynamic scaling
- 🔒 **Enhanced Security**: Multi-layer security implementation
- 🐳 **Custom Dockerfile**: Optimized NGINX container
- 📝 **Better Documentation**: Comprehensive guides and examples
- 🧪 **Testing**: Validation and linting workflows

## 🎯 Production Ready Features

- Self-healing deployments
- Zero-downtime updates
- Automated scaling
- Health monitoring
- Security hardening
- Multi-arch support
- GitOps automation

---

For detailed information, see the main [README.md](../README.md)
