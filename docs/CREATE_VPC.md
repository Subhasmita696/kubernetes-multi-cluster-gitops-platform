# 🌐 Creating a VPC for Your EKS Cluster

If you don't have a VPC with subnets yet, follow this guide!

## 🎯 Quick Option: Use Terraform Module

### Step 1: Create VPC Configuration

Create `terraform/vpc.tf`:

```hcl
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "gitops-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
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
  }
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}
```

### Step 2: Update eks.tf

Replace the hardcoded subnet IDs:

```hcl
resource "aws_eks_cluster" "main" {
  # ... other config ...
  
  vpc_config {
    subnet_ids              = module.vpc.private_subnets  # Use VPC module subnets
    endpoint_private_access = true
    endpoint_public_access  = true
  }
}

resource "aws_eks_node_group" "main" {
  # ... other config ...
  
  subnet_ids = module.vpc.private_subnets  # Use VPC module subnets
}
```

### Step 3: Deploy

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

✅ This creates everything automatically!

---

## 🖱️ Manual Option: AWS Console

### Step 1: Create VPC

1. Go to AWS Console → VPC
2. Click **"Create VPC"**
3. Choose **"VPC and more"**
4. Configure:
   - Name: `gitops-vpc`
   - IPv4 CIDR: `10.0.0.0/16`
   - Number of AZs: `2`
   - Number of public subnets: `2`
   - Number of private subnets: `2`
   - NAT gateways: `1 per AZ`
5. Click **"Create VPC"**

### Step 2: Get Subnet IDs

1. Go to **Subnets** in VPC console
2. Copy the IDs of the **private subnets** (should be 2)
3. They look like: `subnet-0abc123def456789`

### Step 3: Update terraform.tfvars

```bash
subnet_ids = [
  "subnet-0abc123def456789",  # Private subnet 1
  "subnet-0xyz789abc123456"   # Private subnet 2
]
```

---

## 🔍 Verify Your VPC Setup

```bash
# List your VPCs
aws ec2 describe-vpcs --query 'Vpcs[*].[VpcId,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table

# List subnets in your VPC
aws ec2 describe-subnets --filters "Name=vpc-id,Values=vpc-xxxxx" --query 'Subnets[*].[SubnetId,AvailabilityZone,CidrBlock,Tags[?Key==`Name`].Value|[0]]' --output table
```

---

## 💰 Cost Consideration

**VPC is FREE**, but NAT Gateways cost ~$0.045/hour (~$32/month)

### Save Money (for testing):

Use public subnets instead (less secure, but free):

```hcl
module "vpc" {
  # ... other config ...
  
  enable_nat_gateway = false  # Disable NAT Gateway
}

resource "aws_eks_cluster" "main" {
  vpc_config {
    subnet_ids              = module.vpc.public_subnets  # Use public subnets
    endpoint_public_access  = true
  }
}
```

⚠️ **Not recommended for production!**

---

## 🆘 Troubleshooting

### Error: "InvalidSubnet.NotFound"
- Your subnet IDs are wrong
- Run the verify commands above

### Error: "UnsupportedAvailabilityZoneException"
- Your region doesn't support those AZs
- Use `aws ec2 describe-availability-zones --region YOUR-REGION`

### Nodes not joining cluster
- Check security groups allow traffic
- Ensure NAT Gateway is working (for private subnets)

---

## 📚 Resources

- [AWS VPC Terraform Module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)
- [EKS VPC Requirements](https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html)

Need help? Open an issue!
