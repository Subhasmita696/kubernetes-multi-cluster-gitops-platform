provider "aws" {
  region = "eu-north-1"
}

resource "aws_eks_cluster" "main" {
  name     = "gitops-cluster"
  role_arn = "arn:aws:iam::<ACCOUNT_ID>:role/EKSRole"

  vpc_config {
    subnet_ids = ["subnet-xxxx", "subnet-yyyy"]
  }
}