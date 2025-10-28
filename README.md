# Three-Tier AWS Infrastructure with Terraform

This repository contains a production-ready, highly secure, scalable, and fault-tolerant three-tier AWS infrastructure using Terraform for deploying a Java application with RDS MySQL database in the ap-south-1 region.

## Architecture Overview

The infrastructure consists of:

1. **Web Tier**: Application Load Balancer (ALB) in public subnets
2. **Application Tier**: Auto Scaling Group with EC2 instances in private subnets
3. **Database Tier**: RDS MySQL with Multi-AZ deployment in database subnets

### Key Features

- **High Availability**: Multi-AZ deployment across availability zones
- **Security**: Private subnets for application and database tiers, security groups with least privilege access
- **Scalability**: Auto Scaling Group with CloudWatch-based scaling policies
- **Fault Tolerance**: Multi-AZ RDS, NAT Gateways in each AZ, load balancer health checks
- **Monitoring**: CloudWatch logs, metrics, and alarms
- **Encryption**: EBS volumes, RDS storage, and S3 buckets encrypted
- **Backup**: Automated RDS backups with 7-day retention

## Project Structure

```
├── main.tf                          # Main Terraform configuration
├── variables.tf                     # Variable definitions
├── outputs.tf                       # Output definitions
├── backend.tf                       # S3 backend configuration
├── terraform.tfvars.example         # Example variables file
├── backend.tfvars.example           # Example backend configuration
├── modules/                         # Terraform modules
│   ├── vpc/                         # VPC module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── security-groups/             # Security groups module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── rds/                         # RDS module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── alb/                         # Application Load Balancer module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── asg/                         # Auto Scaling Group module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── user_data.sh
└── scripts/                         # Deployment scripts
    └── setup-backend.sh             # S3 backend setup script
```

## Prerequisites

1. **AWS CLI** configured with appropriate credentials
2. **Terraform** >= 1.0 installed
3. **AWS Account** with sufficient permissions
4. **Domain name** (optional, for SSL certificate)

## Quick Start

### 1. Clone and Setup

```bash
git clone <repository-url>
cd AWS-VPC
```

### 2. Configure Backend

```bash
# Create S3 bucket for Terraform state
./scripts/setup-backend.sh

# Update backend configuration
cp backend.tfvars.example backend.tfvars
# Edit backend.tfvars with your bucket name
```

### 3. Configure Variables

```bash
# Copy and edit variables
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### 4. Deploy Infrastructure

```bash
# Initialize Terraform
terraform init -backend-config=backend.tfvars

# Plan deployment
terraform plan

# Apply changes
terraform apply
```

## Configuration

### Required Variables

- `db_password`: Database password (sensitive)
- `ssl_certificate_arn`: SSL certificate ARN for HTTPS (optional)

### Optional Variables

- `aws_region`: AWS region (default: ap-south-1)
- `project_name`: Project name (default: three-tier-app)
- `environment`: Environment name (default: production)
- `vpc_cidr`: VPC CIDR block (default: 10.0.0.0/16)
- `instance_type`: EC2 instance type (default: t3.medium)
- `db_instance_class`: RDS instance class (default: db.t3.medium)

## Infrastructure Components

### VPC Module
- Creates VPC with DNS support
- Public subnets with Internet Gateway
- Private subnets with NAT Gateways
- Database subnets
- Route tables and associations

### Security Groups Module
- ALB security group (HTTP/HTTPS from internet)
- Application security group (HTTP from ALB, SSH from VPC)
- RDS security group (MySQL from application)
- Bastion security group (SSH from specific IPs)

### RDS Module
- MySQL 8.0 with Multi-AZ deployment
- Read replica for read scaling
- Automated backups with 7-day retention
- Encryption at rest with KMS
- Performance Insights and Enhanced Monitoring
- Parameter and option groups

### ALB Module
- Application Load Balancer with HTTP/HTTPS listeners
- Target group with health checks
- S3 bucket for access logs
- CloudWatch alarms for monitoring
- SSL/TLS termination

### ASG Module
- Auto Scaling Group with launch template
- CloudWatch-based scaling policies
- IAM roles and policies for EC2 instances
- User data script for application deployment
- CloudWatch logs and monitoring

## Security Features

1. **Network Security**
   - Private subnets for application and database tiers
   - Security groups with least privilege access
   - NAT Gateways for outbound internet access

2. **Data Security**
   - Encryption at rest for EBS volumes and RDS
   - Encryption in transit for database connections
   - KMS key management

3. **Access Control**
   - IAM roles with minimal required permissions
   - Security groups restricting traffic flow
   - Private database access only

## Monitoring and Logging

1. **CloudWatch Metrics**
   - CPU utilization for auto scaling
   - ALB response time and error rates
   - RDS performance metrics

2. **CloudWatch Logs**
   - Application logs from EC2 instances
   - ALB access logs in S3

3. **CloudWatch Alarms**
   - High CPU utilization
   - ALB response time
   - 5XX error rates

## Scaling

The infrastructure automatically scales based on:

- **CPU Utilization**: Scale up when > 70%, scale down when < 20%
- **Target Response Time**: Monitor ALB response time
- **Health Checks**: Replace unhealthy instances

## Backup and Recovery

1. **RDS Backups**
   - Automated daily backups
   - 7-day retention period
   - Point-in-time recovery

2. **Application Data**
   - EBS snapshots (manual)
   - Application logs in CloudWatch

## Cost Optimization

1. **Instance Types**: Use appropriate instance sizes
2. **Storage**: GP3 volumes for better price/performance
3. **Reserved Instances**: Consider for production workloads
4. **S3 Lifecycle**: Automatic cleanup of old logs

## Troubleshooting

### Common Issues

1. **SSL Certificate**: Ensure certificate is in the same region
2. **Security Groups**: Check inbound/outbound rules
3. **Subnet Configuration**: Verify subnet associations
4. **IAM Permissions**: Ensure sufficient permissions

### Useful Commands

```bash
# Check Terraform state
terraform state list

# Import existing resources
terraform import aws_instance.example i-1234567890abcdef0

# Destroy infrastructure
terraform destroy

# Validate configuration
terraform validate

# Format code
terraform fmt -recursive
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the repository
- Check the troubleshooting section
- Review AWS documentation

## Changelog

### v1.0.0
- Initial release
- Three-tier architecture
- Multi-AZ deployment
- Security best practices
- Monitoring and logging
# AWS-3-Tier-Infra-Provisioning-TF
