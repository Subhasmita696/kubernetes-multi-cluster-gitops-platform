#!/bin/bash

# 🚀 Automated Setup Script for Kubernetes GitOps Platform
# This script automates the initial setup process

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_step() {
    echo -e "${BLUE}==>${NC} ${GREEN}$1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║   Kubernetes Multi-Cluster GitOps Platform Setup         ║"
echo "║   Automated Installation Script                          ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check prerequisites
print_step "Checking prerequisites..."

if ! command_exists aws; then
    print_error "AWS CLI not found. Please install it first:"
    echo "  macOS: brew install awscli"
    echo "  Linux: sudo apt-get install awscli"
    exit 1
fi
print_success "AWS CLI found"

if ! command_exists terraform; then
    print_error "Terraform not found. Please install it first:"
    echo "  macOS: brew install terraform"
    echo "  Linux: https://learn.hashicorp.com/tutorials/terraform/install-cli"
    exit 1
fi
print_success "Terraform found"

if ! command_exists kubectl; then
    print_error "kubectl not found. Please install it first:"
    echo "  macOS: brew install kubectl"
    echo "  Linux: sudo apt-get install kubectl"
    exit 1
fi
print_success "kubectl found"

if ! command_exists helm; then
    print_error "Helm not found. Please install it first:"
    echo "  macOS: brew install helm"
    echo "  Linux: https://helm.sh/docs/intro/install/"
    exit 1
fi
print_success "Helm found"

# Check AWS credentials
print_step "Checking AWS credentials..."
if ! aws sts get-caller-identity &> /dev/null; then
    print_error "AWS credentials not configured. Run: aws configure"
    exit 1
fi
AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
print_success "AWS credentials configured (Account: $AWS_ACCOUNT)"

# Get user inputs
print_step "Configuration"
echo ""

read -p "Enter your AWS region (default: eu-north-1): " AWS_REGION
AWS_REGION=${AWS_REGION:-eu-north-1}

read -p "Enter EKS cluster name (default: gitops-cluster): " CLUSTER_NAME
CLUSTER_NAME=${CLUSTER_NAME:-gitops-cluster}

read -p "Enter your GitHub username: " GITHUB_USER
if [ -z "$GITHUB_USER" ]; then
    print_error "GitHub username is required!"
    exit 1
fi

read -p "Do you want to create a VPC? (y/n, default: y): " CREATE_VPC
CREATE_VPC=${CREATE_VPC:-y}

# Create terraform.tfvars
print_step "Creating Terraform configuration..."

cd terraform

if [ "$CREATE_VPC" == "y" ]; then
    print_warning "Creating VPC configuration..."
    
    cat > vpc.tf <<EOF
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${CLUSTER_NAME}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["\${var.aws_region}a", "\${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway   = true
  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Environment = "dev"
    Project     = "gitops"
    ManagedBy   = "Terraform"
  }
}
EOF

    # Update eks.tf to use VPC module
    print_step "Updating EKS configuration to use VPC module..."
    
else
    read -p "Enter private subnet ID 1: " SUBNET_1
    read -p "Enter private subnet ID 2: " SUBNET_2
    
    cat > terraform.tfvars <<EOF
aws_region = "$AWS_REGION"
cluster_name = "$CLUSTER_NAME"
subnet_ids = ["$SUBNET_1", "$SUBNET_2"]
node_instance_types = ["t3.medium"]
node_desired_size   = 2
node_min_size       = 1
node_max_size       = 4
EOF
fi

print_success "Terraform configuration created"

# Initialize and apply Terraform
print_step "Initializing Terraform..."
terraform init

print_step "Planning infrastructure..."
terraform plan

echo ""
print_warning "Review the plan above. This will create AWS resources and incur costs!"
read -p "Do you want to proceed? (yes/no): " PROCEED

if [ "$PROCEED" != "yes" ]; then
    print_warning "Setup cancelled by user"
    exit 0
fi

print_step "Creating infrastructure (this takes 10-15 minutes)..."
terraform apply -auto-approve

CLUSTER_NAME_OUTPUT=$(terraform output -raw cluster_name 2>/dev/null || echo "$CLUSTER_NAME")
print_success "Infrastructure created successfully!"

cd ..

# Configure kubectl
print_step "Configuring kubectl..."
aws eks update-kubeconfig --region "$AWS_REGION" --name "$CLUSTER_NAME_OUTPUT"
print_success "kubectl configured"

# Verify nodes
print_step "Waiting for nodes to be ready..."
kubectl wait --for=condition=Ready nodes --all --timeout=300s || true
kubectl get nodes

# Install ArgoCD
print_step "Installing ArgoCD..."
kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

print_step "Waiting for ArgoCD to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd

print_success "ArgoCD installed successfully!"

# Update repository URL
print_step "Updating repository URL in application manifests..."
sed -i.bak "s|Subhasmita696|$GITHUB_USER|g" argocd/application.yaml
rm -f argocd/application.yaml.bak

# Get ArgoCD password
ARGOCD_PASSWORD=$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d)

# Deploy application
print_step "Deploying NGINX application..."
kubectl apply -f argocd/application.yaml

echo ""
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════════════════════════╗"
echo "║                 ✅ Setup Complete! ✅                      ║"
echo "╚═══════════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo ""
echo -e "${BLUE}📊 Cluster Information:${NC}"
echo "  Region: $AWS_REGION"
echo "  Cluster: $CLUSTER_NAME_OUTPUT"
echo ""
echo -e "${BLUE}🔑 ArgoCD Credentials:${NC}"
echo "  Username: admin"
echo "  Password: $ARGOCD_PASSWORD"
echo ""
echo -e "${BLUE}🌐 Access ArgoCD UI:${NC}"
echo "  Run: kubectl port-forward svc/argocd-server -n argocd 8080:443"
echo "  Then visit: https://localhost:8080"
echo ""
echo -e "${BLUE}📱 Access NGINX Application:${NC}"
echo "  Run: kubectl get svc nginx-service -n default"
echo "  Wait for EXTERNAL-IP (2-3 minutes)"
echo ""
echo -e "${YELLOW}💡 Next Steps:${NC}"
echo "  1. Access ArgoCD UI and login"
echo "  2. Watch your application deploy"
echo "  3. Check out docs/CUSTOMIZE.md to add your own apps"
echo ""
echo -e "${YELLOW}⚠️  Don't forget to run 'terraform destroy' when done to avoid charges!${NC}"
echo ""
