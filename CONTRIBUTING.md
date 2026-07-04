# Contributing to Kubernetes Multi-Cluster GitOps Platform

Thank you for your interest in contributing! This document provides guidelines for contributing to this project.

## 🚀 Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/kubernetes-multi-cluster-gitops-platform.git`
3. Create a feature branch: `git checkout -b feature/amazing-feature`
4. Make your changes
5. Commit your changes: `git commit -m 'feat: add amazing feature'`
6. Push to the branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## 📝 Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation changes
- `chore:` - Maintenance tasks
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `ci:` - CI/CD changes

Examples:
```
feat: add prometheus monitoring stack
fix: resolve ArgoCD sync issue
docs: update README with installation steps
chore: upgrade nginx to 1.27
```

## 🔍 Code Review Process

1. All submissions require review before merging
2. Ensure all CI checks pass
3. Update documentation for any user-facing changes
4. Add tests if applicable

## 🛡️ Security Guidelines

- Never commit secrets, credentials, or sensitive data
- Use Kubernetes secrets for sensitive configuration
- Follow least privilege principle for IAM roles
- Run security scans before submitting PRs

## 📋 Pull Request Checklist

- [ ] Code follows project conventions
- [ ] Documentation updated (if needed)
- [ ] CI/CD pipeline passes
- [ ] Security scan shows no critical issues
- [ ] Tested in local environment
- [ ] Commit messages follow convention

## 🧪 Testing

Before submitting:

```bash
# Validate Terraform
cd terraform
terraform fmt -check
terraform validate

# Validate Kubernetes manifests
kubectl apply --dry-run=client -f argocd/

# Lint Helm charts
helm lint argocd/apps/nginx/helm-charts/nginx-chart/
```

## 📞 Questions?

Feel free to open an issue for any questions or concerns.

## 📜 License

By contributing, you agree that your contributions will be licensed under the same license as the project.
