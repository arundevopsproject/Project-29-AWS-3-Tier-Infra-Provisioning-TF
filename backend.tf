# S3 Backend Configuration for Terraform State Management
# This file should be used with terraform init -backend-config=backend.tfvars

terraform {
  backend "s3" {
    # These values will be provided via backend.tfvars file
    # bucket = "your-terraform-state-bucket-name"
    # key    = "three-tier-infrastructure/terraform.tfstate"
    # region = "ap-south-1"
    # encrypt = true
  }
}

