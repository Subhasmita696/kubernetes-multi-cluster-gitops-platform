# 🎨 Customization Guide

Learn how to customize this platform for your own applications!

## 📝 Table of Contents
1. [Adding Your Own Application](#adding-your-own-application)
2. [Changing the Region](#changing-the-region)
3. [Customizing Cluster Size](#customizing-cluster-size)
4. [Adding Multiple Applications](#adding-multiple-applications)
5. [Environment Setup (Dev/Staging/Prod)](#environment-setup)

---

## 🚀 Adding Your Own Application

### Step 1: Create Application Directory

```bash
cd argocd/apps
mkdir my-app
cd my-app
```

### Step 2: Create Kubernetes Manifests

Create `deployment.yaml`:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
  labels:
    app: my-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: YOUR-DOCKER-IMAGE:TAG
        ports:
        - containerPort: 8080
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
```

Create `service.yaml`:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  type: LoadBalancer
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 8080
```

### Step 3: Create ArgoCD Application

Create `argocd/my-app-application.yaml`:
```yaml
apiVersion: argoproj.io/v1beta1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/YOUR-USERNAME/YOUR-REPO
    targetRevision: HEAD
    path: argocd/apps/my-app
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### Step 4: Deploy

```bash
kubectl apply -f argocd/my-app-application.yaml
```

✅ Done! ArgoCD will automatically deploy your app!

---

## 🌍 Changing the Region

### Option 1: Edit terraform.tfvars

```bash
# Edit terraform/terraform.tfvars
aws_region = "us-east-1"  # Change to your preferred region
```

### Option 2: Supported Regions

Popular regions:
- `us-east-1` - US East (N. Virginia)
- `us-west-2` - US West (Oregon)
- `eu-west-1` - Europe (Ireland)
- `eu-north-1` - Europe (Stockholm)
- `ap-southeast-1` - Asia Pacific (Singapore)

After changing:
```bash
cd terraform
terraform plan
terraform apply
```

---

## 📊 Customizing Cluster Size

### Edit Node Configuration

Edit `terraform/terraform.tfvars`:

```bash
# For small projects (saves money!)
node_instance_types = ["t3.small"]
node_desired_size   = 1
node_min_size       = 1
node_max_size       = 2

# For medium projects
node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 5

# For production (high availability)
node_instance_types = ["t3.large"]
node_desired_size   = 3
node_min_size       = 2
node_max_size       = 10
```

Apply changes:
```bash
cd terraform
terraform apply
```

---

## 🔢 Adding Multiple Applications

### Organize Your Apps

```
argocd/apps/
├── frontend/
│   ├── deployment.yaml
│   └── service.yaml
├── backend/
│   ├── deployment.yaml
│   └── service.yaml
└── database/
    ├── statefulset.yaml
    └── service.yaml
```

### Create App-of-Apps Pattern

Create `argocd/app-of-apps.yaml`:
```yaml
apiVersion: argoproj.io/v1beta1
kind: Application
metadata:
  name: app-of-apps
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/YOUR-USERNAME/YOUR-REPO
    targetRevision: HEAD
    path: argocd/applications
  destination:
    server: https://kubernetes.default.svc
    namespace: argocd
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

Create individual app manifests in `argocd/applications/`:
- `frontend.yaml`
- `backend.yaml`
- `database.yaml`

Deploy all at once:
```bash
kubectl apply -f argocd/app-of-apps.yaml
```

---

## 🏢 Environment Setup (Dev/Staging/Prod)

### Method 1: Multiple Clusters

```bash
# Create dev cluster
terraform workspace new dev
terraform apply -var-file=dev.tfvars

# Create staging cluster
terraform workspace new staging
terraform apply -var-file=staging.tfvars

# Create prod cluster
terraform workspace new prod
terraform apply -var-file=prod.tfvars
```

### Method 2: Namespaces (Single Cluster)

```bash
# Create namespaces
kubectl create namespace dev
kubectl create namespace staging
kubectl create namespace prod
```

Update ArgoCD applications to target different namespaces:
```yaml
destination:
  server: https://kubernetes.default.svc
  namespace: dev  # or staging, or prod
```

### Method 3: Kustomize Overlays

```
argocd/apps/my-app/
├── base/
│   ├── deployment.yaml
│   └── service.yaml
└── overlays/
    ├── dev/
    │   └── kustomization.yaml
    ├── staging/
    │   └── kustomization.yaml
    └── prod/
        └── kustomization.yaml
```

---

## 🎛️ Common Customizations

### Change NGINX to Your App

1. Replace Dockerfile:
```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

2. Update deployment image:
```yaml
containers:
- name: my-app
  image: ghcr.io/YOUR-USERNAME/my-app:latest
```

### Add Environment Variables

```yaml
containers:
- name: my-app
  image: my-image:latest
  env:
  - name: DATABASE_URL
    value: "postgres://db:5432/mydb"
  - name: API_KEY
    valueFrom:
      secretKeyRef:
        name: api-secrets
        key: api-key
```

### Add ConfigMaps

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  config.json: |
    {
      "port": 8080,
      "logLevel": "info"
    }
```

---

## 📚 Next Steps

- 🔒 [Security Hardening](SECURITY.md)
- 📊 [Add Monitoring](MONITORING.md)
- 🔄 [Advanced GitOps](ADVANCED.md)
- 💾 [Database Setup](DATABASE.md)

Need help? Open an issue!
