# Variables for EC2 Instance Module

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs where instances will be launched"
  type        = list(string)
}

variable "instance_count" {
  description = "Number of EC2 instances to create"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.medium"
}

variable "ami_id" {
  description = "AMI ID for instances (if not provided, latest Ubuntu 22.04 will be used)"
  type        = string
  default     = ""
}

variable "key_name" {
  description = "Name of the EC2 Key Pair for SSH access"
  type        = string
  default     = ""
}

variable "create_key_pair" {
  description = "Whether to create a new key pair"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Public key for the key pair (required if create_key_pair is true)"
  type        = string
  default     = ""
}

variable "volume_size" {
  description = "Size of the EBS volume in GB"
  type        = number
  default     = 20
}

variable "volume_iops" {
  description = "IOPS for the EBS volume (only for gp3)"
  type        = number
  default     = 3000
}

variable "volume_throughput" {
  description = "Throughput for the EBS volume in MiB/s (only for gp3)"
  type        = number
  default     = 125
}

variable "app_port" {
  description = "Port on which the application runs"
  type        = number
  default     = 8080
}

variable "db_endpoint" {
  description = "RDS endpoint"
  type        = string
  default     = ""
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database username"
  type        = string
  default     = "admin"
}

variable "install_docker" {
  description = "Whether to install Docker on the instances"
  type        = bool
  default     = false
}

variable "allow_http" {
  description = "Whether to allow HTTP traffic"
  type        = bool
  default     = true
}

variable "allow_https" {
  description = "Whether to allow HTTPS traffic"
  type        = bool
  default     = false
}

variable "allow_ssh" {
  description = "Whether to allow SSH traffic"
  type        = bool
  default     = true
}

variable "alb_security_group_ids" {
  description = "List of ALB security group IDs"
  type        = list(string)
  default     = []
}

variable "additional_security_group_ids" {
  description = "Additional security group IDs to attach"
  type        = list(string)
  default     = []
}

variable "http_cidr_blocks" {
  description = "CIDR blocks allowed for HTTP traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "https_cidr_blocks" {
  description = "CIDR blocks allowed for HTTPS traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "ssh_cidr_blocks" {
  description = "CIDR blocks allowed for SSH traffic"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "cpu_threshold_high" {
  description = "CPU threshold for high utilization alarm"
  type        = number
  default     = 80
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for CloudWatch alarms"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

