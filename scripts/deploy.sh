#!/bin/bash

# Deployment script for Three-Tier AWS Infrastructure
# This script automates the deployment process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  Three-Tier AWS Infrastructure Deploy  ${NC}"
echo -e "${BLUE}========================================${NC}"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command_exists terraform; then
    echo -e "${RED}Terraform is not installed. Please install it first.${NC}"
    exit 1
fi

if ! command_exists aws; then
    echo -e "${RED}AWS CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check AWS credentials
if ! aws sts get-caller-identity >/dev/null 2>&1; then
    echo -e "${RED}AWS credentials not configured. Please run 'aws configure' first.${NC}"
    exit 1
fi

echo -e "${GREEN}Prerequisites check passed!${NC}"

# Check if backend.tfvars exists
if [ ! -f "$PROJECT_DIR/backend.tfvars" ]; then
    echo -e "${YELLOW}backend.tfvars not found. Creating from example...${NC}"
    cp "$PROJECT_DIR/backend.tfvars.example" "$PROJECT_DIR/backend.tfvars"
    echo -e "${RED}Please edit backend.tfvars with your S3 bucket name and run this script again.${NC}"
    exit 1
fi

# Check if terraform.tfvars exists
if [ ! -f "$PROJECT_DIR/terraform.tfvars" ]; then
    echo -e "${YELLOW}terraform.tfvars not found. Creating from example...${NC}"
    cp "$PROJECT_DIR/terraform.tfvars.example" "$PROJECT_DIR/terraform.tfvars"
    echo -e "${RED}Please edit terraform.tfvars with your configuration and run this script again.${NC}"
    exit 1
fi

# Change to project directory
cd "$PROJECT_DIR"

# Initialize Terraform
echo -e "${YELLOW}Initializing Terraform...${NC}"
terraform init -backend-config=backend.tfvars

# Validate configuration
echo -e "${YELLOW}Validating Terraform configuration...${NC}"
terraform validate

# Format code
echo -e "${YELLOW}Formatting Terraform code...${NC}"
terraform fmt -recursive

# Plan deployment
echo -e "${YELLOW}Planning deployment...${NC}"
terraform plan -out=tfplan

# Ask for confirmation
echo -e "${YELLOW}Do you want to apply these changes? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    echo -e "${YELLOW}Applying changes...${NC}"
    terraform apply tfplan
    
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  Deployment completed successfully!   ${NC}"
    echo -e "${GREEN}========================================${NC}"
    
    # Display outputs
    echo -e "${YELLOW}Infrastructure outputs:${NC}"
    terraform output
    
    # Clean up plan file
    rm -f tfplan
    
else
    echo -e "${YELLOW}Deployment cancelled.${NC}"
    rm -f tfplan
    exit 0
fi

