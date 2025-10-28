# Variables for ElastiCache Module

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for ElastiCache"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group ID for ElastiCache"
  type        = string
}

variable "node_type" {
  description = "ElastiCache node type"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_nodes" {
  description = "Number of cache nodes in the cluster"
  type        = number
  default     = 2
}

variable "snapshot_retention_limit" {
  description = "Number of days to retain snapshots"
  type        = number
  default     = 5
}

variable "snapshot_window" {
  description = "Daily time range for snapshots"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Weekly time range for maintenance"
  type        = string
  default     = "sun:05:00-sun:09:00"
}

variable "auth_token" {
  description = "Auth token for Redis (leave empty to disable auth)"
  type        = string
  default     = ""
  sensitive   = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "cpu_threshold_high" {
  description = "CPU threshold for high utilization alarm"
  type        = number
  default     = 80
}

variable "memory_threshold_high" {
  description = "Memory threshold for high utilization alarm"
  type        = number
  default     = 80
}

variable "evictions_threshold" {
  description = "Threshold for evictions alarm"
  type        = number
  default     = 100
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic for alarms"
  type        = string
  default     = ""
}

# Read Replica Configuration
variable "create_read_replica" {
  description = "Whether to create a read replica cluster"
  type        = bool
  default     = false
}

variable "read_replica_node_type" {
  description = "Node type for read replica cluster"
  type        = string
  default     = "cache.t3.micro"
}

variable "read_replica_num_nodes" {
  description = "Number of nodes in read replica cluster"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

