# Main Terraform configuration for Three-Tier AWS Infrastructure
# Production deployment for Java application with RDS MySQL

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  
  backend "s3" {
    # S3 backend configuration will be provided via terraform init
    # bucket = "your-terraform-state-bucket"
    # key    = "three-tier-infrastructure/terraform.tfstate"
    # region = "ap-south-1"
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Data sources
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_caller_identity" "current" {}

# VPC Module
module "vpc" {
  source = "./modules/vpc"
  
  project_name     = var.project_name
  environment      = var.environment
  vpc_cidr         = var.vpc_cidr
  availability_zones = data.aws_availability_zones.available.names
  
  tags = var.tags
}

# Security Groups Module
module "security_groups" {
  source = "./modules/security-groups"
  
  vpc_id = module.vpc.vpc_id
  bastion_allowed_cidrs = var.bastion_allowed_cidrs
  
  tags = var.tags
}

# RDS Module
module "rds" {
  source = "./modules/rds"
  
  project_name    = var.project_name
  environment     = var.environment
  vpc_id          = module.vpc.vpc_id
  private_subnets = module.vpc.private_subnet_ids
  db_security_group_id = module.security_groups.rds_security_group_id
  db_subnet_group_name = module.vpc.db_subnet_group_name
  
  db_instance_class    = var.db_instance_class
  db_allocated_storage = var.db_allocated_storage
  db_engine_version    = var.db_engine_version
  db_name              = var.db_name
  db_username          = var.db_username
  db_password          = var.db_password
  
  tags = var.tags
}

# Application Load Balancer Module
module "alb" {
  source = "./modules/alb"
  
  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  public_subnets   = module.vpc.public_subnet_ids
  alb_security_group_id = module.security_groups.alb_security_group_id
  
  tags = var.tags
}

# EC2 Instance Module (for standalone instances)
module "ec2" {
  source = "./modules/ec2"
  
  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  subnet_ids       = module.vpc.private_subnet_ids
  
  instance_count   = var.ec2_instance_count
  instance_type    = var.instance_type
  
  db_endpoint = module.rds.rds_endpoint
  db_name     = var.db_name
  db_username = var.db_username
  
  allow_http = true
  allow_ssh  = true
  ssh_cidr_blocks = ["10.0.0.0/16"] # Only from VPC
  
  tags = var.tags
}

# SNS Module for Notifications
module "sns" {
  source = "./modules/sns"
  
  project_name = var.project_name
  environment  = var.environment
  
  alert_email_addresses = var.alert_email_addresses
  alert_sms_numbers     = var.alert_sms_numbers
  notification_email_addresses = var.notification_email_addresses
  
  tags = var.tags
}

# Secrets Manager Module
module "secrets_manager" {
  source = "./modules/secrets-manager"
  
  project_name = var.project_name
  environment  = var.environment
  
  db_username = var.db_username
  db_password = var.db_password
  db_endpoint = module.rds.rds_endpoint
  db_name     = var.db_name
  
  redis_auth_token = var.redis_auth_token
  redis_endpoint   = module.elasticache.primary_endpoint
  
  jwt_secret     = var.jwt_secret
  api_key        = var.api_key
  encryption_key = var.encryption_key
  
  sns_topic_arn = module.sns.alerts_topic_arn
  
  tags = var.tags
}

# ElastiCache Module
module "elasticache" {
  source = "./modules/elasticache"
  
  project_name = var.project_name
  environment  = var.environment
  
  subnet_ids       = module.vpc.database_subnet_ids
  security_group_id = module.security_groups.redis_security_group_id
  
  node_type = var.redis_node_type
  num_cache_nodes = var.redis_num_nodes
  auth_token = var.redis_auth_token
  
  sns_topic_arn = module.sns.alerts_topic_arn
  
  tags = var.tags
}

# WAF Module
module "waf" {
  source = "./modules/waf"
  
  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  
  alb_arn = module.alb.alb_arn
  
  rate_limit = var.waf_rate_limit
  blocked_countries = var.waf_blocked_countries
  allowed_ips = var.waf_allowed_ips
  
  sns_topic_arn = module.sns.alerts_topic_arn
  
  tags = var.tags
}

# VPC Flow Logs Module
module "vpc_flow_logs" {
  source = "./modules/vpc-flow-logs"
  
  project_name = var.project_name
  environment  = var.environment
  
  vpc_id = module.vpc.vpc_id
  
  flow_logs_retention_days = var.flow_logs_retention_days
  enable_cloudwatch_logs = var.enable_cloudwatch_flow_logs
  
  sns_topic_arn = module.sns.alerts_topic_arn
  
  tags = var.tags
}

# Security Hardening Module
module "security_hardening" {
  source = "./modules/security-hardening"
  
  project_name = var.project_name
  environment  = var.environment
  
  tags = var.tags
}

# Auto Scaling Group Module
module "asg" {
  source = "./modules/asg"
  
  project_name     = var.project_name
  environment      = var.environment
  vpc_id           = module.vpc.vpc_id
  private_subnets  = module.vpc.private_subnet_ids
  app_security_group_id = module.security_groups.app_security_group_id
  target_group_arn = module.alb.target_group_arn
  
  instance_type    = var.instance_type
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity
  
  db_endpoint = module.rds.rds_endpoint
  db_name     = var.db_name
  db_username = var.db_username
  
  tags = var.tags
}

