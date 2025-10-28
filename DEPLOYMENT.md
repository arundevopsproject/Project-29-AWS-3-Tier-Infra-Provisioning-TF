# Deployment Guide

This guide provides step-by-step instructions for deploying the Three-Tier AWS Infrastructure.

## Prerequisites

### 1. AWS Account Setup
- AWS account with appropriate permissions
- AWS CLI installed and configured
- Terraform >= 1.0 installed

### 2. Required Permissions
Your AWS user/role needs the following permissions:
- EC2 (instances, security groups, key pairs, etc.)
- VPC (VPC, subnets, route tables, etc.)
- RDS (database instances, subnet groups, etc.)
- ELB (load balancers, target groups, etc.)
- IAM (roles, policies, instance profiles)
- S3 (buckets, objects)
- CloudWatch (logs, metrics, alarms)
- KMS (key management)

### 3. Domain and SSL Certificate (Optional)
- Domain name registered
- SSL certificate in AWS Certificate Manager (ACM)
- Certificate must be in the same region (ap-south-1)

## Step-by-Step Deployment

### Step 1: Clone Repository
```bash
git clone <repository-url>
cd AWS-VPC
```

### Step 2: Setup S3 Backend
```bash
# Run the backend setup script
./scripts/setup-backend.sh

# Or manually create S3 bucket with:
# - Versioning enabled
# - Server-side encryption
# - Public access blocked
# - Lifecycle policy for old versions
```

### Step 3: Configure Backend
```bash
# Copy and edit backend configuration
cp backend.tfvars.example backend.tfvars

# Edit backend.tfvars with your values:
# bucket = "your-terraform-state-bucket-name"
# key = "three-tier-infrastructure/terraform.tfstate"
# region = "ap-south-1"
# encrypt = true
```

### Step 4: Configure Variables
```bash
# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars

# Edit terraform.tfvars with your values:
# - db_password: Strong database password
# - ssl_certificate_arn: Your SSL certificate ARN (optional)
# - Other variables as needed
```

### Step 5: Deploy Infrastructure

#### Option A: Using Deployment Script
```bash
# Linux/Mac
./scripts/deploy.sh

# Windows PowerShell
.\scripts\deploy.ps1
```

#### Option B: Manual Deployment
```bash
# Initialize Terraform
terraform init -backend-config=backend.tfvars

# Validate configuration
terraform validate

# Plan deployment
terraform plan

# Apply changes
terraform apply
```

### Step 6: Verify Deployment
```bash
# Check outputs
terraform output

# Verify resources in AWS Console
# - VPC and subnets
# - Security groups
# - RDS instance
# - Application Load Balancer
# - Auto Scaling Group
```

## Post-Deployment Configuration

### 1. Database Setup
```bash
# Get database endpoint
terraform output rds_endpoint

# Connect to database and create tables
mysql -h <rds-endpoint> -u admin -p
```

### 2. Application Deployment
- Update the user data script in `modules/asg/user_data.sh`
- Replace placeholder application with your actual Java application
- Ensure health check endpoint is available at `/health`

### 3. SSL Certificate (Optional)
- Request certificate in AWS Certificate Manager
- Update `ssl_certificate_arn` in terraform.tfvars
- Run `terraform apply` to update ALB

### 4. Domain Configuration
- Create Route 53 hosted zone
- Add ALB DNS name as A record
- Update DNS settings with your domain registrar

## Monitoring Setup

### 1. CloudWatch Dashboards
- Create custom dashboards for monitoring
- Add widgets for key metrics

### 2. SNS Notifications
- Create SNS topic for alerts
- Subscribe to email/SMS notifications
- Update `sns_topic_arn` in terraform.tfvars

### 3. Log Aggregation
- Configure log shipping to external systems
- Set up log analysis tools

## Security Hardening

### 1. Network Security
- Review security group rules
- Implement WAF for ALB
- Consider VPC Flow Logs

### 2. Access Control
- Use IAM roles with least privilege
- Enable MFA for AWS console access
- Implement bastion host for SSH access

### 3. Data Protection
- Enable RDS encryption
- Use AWS Secrets Manager for passwords
- Implement backup encryption

## Scaling Configuration

### 1. Auto Scaling
- Adjust scaling policies based on load
- Configure predictive scaling
- Set up scheduled scaling

### 2. Database Scaling
- Enable read replicas for read scaling
- Consider Aurora for better performance
- Implement connection pooling

### 3. Caching
- Add ElastiCache for Redis/Memcached
- Implement application-level caching
- Use CloudFront for static content

## Backup and Recovery

### 1. Database Backups
- Verify automated backups
- Test point-in-time recovery
- Implement cross-region backups

### 2. Application Backups
- Backup application code
- Store configuration in version control
- Document recovery procedures

### 3. Disaster Recovery
- Create multi-region deployment
- Implement backup and restore procedures
- Test disaster recovery scenarios

## Troubleshooting

### Common Issues

1. **SSL Certificate Issues**
   - Ensure certificate is in the same region
   - Verify domain validation
   - Check certificate status

2. **Security Group Issues**
   - Review inbound/outbound rules
   - Check subnet associations
   - Verify VPC configuration

3. **Database Connection Issues**
   - Check security group rules
   - Verify subnet group configuration
   - Test connectivity from application

4. **Load Balancer Issues**
   - Check target group health
   - Verify security group rules
   - Review listener configuration

### Useful Commands

```bash
# Check Terraform state
terraform state list

# Import existing resources
terraform import aws_instance.example i-1234567890abcdef0

# Refresh state
terraform refresh

# Destroy infrastructure
terraform destroy

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

## Maintenance

### Regular Tasks
- Update AMI IDs
- Review and update security groups
- Monitor costs and optimize resources
- Update Terraform and provider versions
- Review and rotate secrets

### Monitoring
- Check CloudWatch alarms
- Review application logs
- Monitor performance metrics
- Track cost trends

## Support

For issues and questions:
1. Check the troubleshooting section
2. Review AWS documentation
3. Create an issue in the repository
4. Contact AWS support if needed

