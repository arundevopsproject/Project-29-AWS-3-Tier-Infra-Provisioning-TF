#!/bin/bash

# Script to create S3 bucket for Terraform state management
# This script creates the S3 bucket with proper security settings

set -e

# Configuration
BUCKET_NAME="your-terraform-state-bucket-name"
REGION="ap-south-1"
PROJECT_NAME="three-tier-app"
ENVIRONMENT="production"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Setting up S3 backend for Terraform state management...${NC}"

# Check if AWS CLI is installed
if ! command -v aws &> /dev/null; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if bucket already exists
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'; then
    echo -e "${YELLOW}Creating S3 bucket: $BUCKET_NAME${NC}"
    
    # Create bucket
    if [ "$REGION" = "us-east-1" ]; then
        aws s3 mb s3://$BUCKET_NAME
    else
        aws s3 mb s3://$BUCKET_NAME --region $REGION
    fi
    
    echo -e "${GREEN}S3 bucket created successfully!${NC}"
else
    echo -e "${YELLOW}S3 bucket already exists: $BUCKET_NAME${NC}"
fi

# Enable versioning
echo -e "${YELLOW}Enabling versioning on S3 bucket...${NC}"
aws s3api put-bucket-versioning \
    --bucket $BUCKET_NAME \
    --versioning-configuration Status=Enabled

# Enable server-side encryption
echo -e "${YELLOW}Enabling server-side encryption on S3 bucket...${NC}"
aws s3api put-bucket-encryption \
    --bucket $BUCKET_NAME \
    --server-side-encryption-configuration '{
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }'

# Block public access
echo -e "${YELLOW}Blocking public access on S3 bucket...${NC}"
aws s3api put-public-access-block \
    --bucket $BUCKET_NAME \
    --public-access-block-configuration \
    BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true

# Add lifecycle policy
echo -e "${YELLOW}Adding lifecycle policy to S3 bucket...${NC}"
aws s3api put-bucket-lifecycle-configuration \
    --bucket $BUCKET_NAME \
    --lifecycle-configuration '{
        "Rules": [
            {
                "ID": "DeleteOldVersions",
                "Status": "Enabled",
                "NoncurrentVersionExpiration": {
                    "NoncurrentDays": 30
                }
            }
        ]
    }'

# Add tags
echo -e "${YELLOW}Adding tags to S3 bucket...${NC}"
aws s3api put-bucket-tagging \
    --bucket $BUCKET_NAME \
    --tagging "TagSet=[{Key=Project,Value=$PROJECT_NAME},{Key=Environment,Value=$ENVIRONMENT},{Key=Purpose,Value=TerraformState},{Key=ManagedBy,Value=Terraform}]"

echo -e "${GREEN}S3 backend setup completed successfully!${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Update backend.tfvars with your bucket name: $BUCKET_NAME"
echo "2. Run: terraform init -backend-config=backend.tfvars"
echo "3. Run: terraform plan"
echo "4. Run: terraform apply"

