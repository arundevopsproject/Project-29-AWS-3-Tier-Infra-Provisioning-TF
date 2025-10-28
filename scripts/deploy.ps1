# PowerShell deployment script for Three-Tier AWS Infrastructure
# This script automates the deployment process on Windows

param(
    [switch]$SkipConfirmation
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"

# Configuration
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectDir = Split-Path -Parent $ScriptDir

Write-Host "========================================" -ForegroundColor $Blue
Write-Host "  Three-Tier AWS Infrastructure Deploy  " -ForegroundColor $Blue
Write-Host "========================================" -ForegroundColor $Blue

# Function to check if command exists
function Test-Command {
    param($Command)
    try {
        Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Check prerequisites
Write-Host "Checking prerequisites..." -ForegroundColor $Yellow

if (-not (Test-Command "terraform")) {
    Write-Host "Terraform is not installed. Please install it first." -ForegroundColor $Red
    exit 1
}

if (-not (Test-Command "aws")) {
    Write-Host "AWS CLI is not installed. Please install it first." -ForegroundColor $Red
    exit 1
}

# Check AWS credentials
try {
    aws sts get-caller-identity | Out-Null
}
catch {
    Write-Host "AWS credentials not configured. Please run 'aws configure' first." -ForegroundColor $Red
    exit 1
}

Write-Host "Prerequisites check passed!" -ForegroundColor $Green

# Check if backend.tfvars exists
if (-not (Test-Path "$ProjectDir\backend.tfvars")) {
    Write-Host "backend.tfvars not found. Creating from example..." -ForegroundColor $Yellow
    Copy-Item "$ProjectDir\backend.tfvars.example" "$ProjectDir\backend.tfvars"
    Write-Host "Please edit backend.tfvars with your S3 bucket name and run this script again." -ForegroundColor $Red
    exit 1
}

# Check if terraform.tfvars exists
if (-not (Test-Path "$ProjectDir\terraform.tfvars")) {
    Write-Host "terraform.tfvars not found. Creating from example..." -ForegroundColor $Yellow
    Copy-Item "$ProjectDir\terraform.tfvars.example" "$ProjectDir\terraform.tfvars"
    Write-Host "Please edit terraform.tfvars with your configuration and run this script again." -ForegroundColor $Red
    exit 1
}

# Change to project directory
Set-Location $ProjectDir

# Initialize Terraform
Write-Host "Initializing Terraform..." -ForegroundColor $Yellow
terraform init -backend-config=backend.tfvars

# Validate configuration
Write-Host "Validating Terraform configuration..." -ForegroundColor $Yellow
terraform validate

# Format code
Write-Host "Formatting Terraform code..." -ForegroundColor $Yellow
terraform fmt -recursive

# Plan deployment
Write-Host "Planning deployment..." -ForegroundColor $Yellow
terraform plan -out=tfplan

# Ask for confirmation
if (-not $SkipConfirmation) {
    $response = Read-Host "Do you want to apply these changes? (y/N)"
    if ($response -match "^[yY]([eE][sS])?$") {
        $apply = $true
    } else {
        $apply = $false
    }
} else {
    $apply = $true
}

if ($apply) {
    Write-Host "Applying changes..." -ForegroundColor $Yellow
    terraform apply tfplan
    
    Write-Host "========================================" -ForegroundColor $Green
    Write-Host "  Deployment completed successfully!   " -ForegroundColor $Green
    Write-Host "========================================" -ForegroundColor $Green
    
    # Display outputs
    Write-Host "Infrastructure outputs:" -ForegroundColor $Yellow
    terraform output
    
    # Clean up plan file
    Remove-Item tfplan -ErrorAction SilentlyContinue
} else {
    Write-Host "Deployment cancelled." -ForegroundColor $Yellow
    Remove-Item tfplan -ErrorAction SilentlyContinue
    exit 0
}

