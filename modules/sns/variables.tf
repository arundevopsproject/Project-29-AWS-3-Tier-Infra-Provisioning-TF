# Variables for SNS Module

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "alert_email_addresses" {
  description = "List of email addresses for alerts"
  type        = list(string)
  default     = []
}

variable "alert_sms_numbers" {
  description = "List of SMS numbers for critical alerts"
  type        = list(string)
  default     = []
}

variable "notification_email_addresses" {
  description = "List of email addresses for general notifications"
  type        = list(string)
  default     = []
}

variable "lambda_function_arn" {
  description = "ARN of Lambda function for processing alerts"
  type        = string
  default     = ""
}

variable "sqs_queue_arn" {
  description = "ARN of SQS queue for processing alerts"
  type        = string
  default     = ""
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 7
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

