# Outputs for VPC Flow Logs Module

output "s3_bucket_name" {
  description = "Name of the S3 bucket for VPC Flow Logs"
  value       = aws_s3_bucket.flow_logs.bucket
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for VPC Flow Logs"
  value       = aws_s3_bucket.flow_logs.arn
}

output "flow_log_id" {
  description = "ID of the VPC Flow Log"
  value       = aws_flow_log.vpc.id
}

output "flow_log_arn" {
  description = "ARN of the VPC Flow Log"
  value       = aws_flow_log.vpc.arn
}

output "iam_role_arn" {
  description = "ARN of the IAM role for VPC Flow Logs"
  value       = aws_iam_role.flow_logs.arn
}

output "cloudwatch_log_group_name" {
  description = "Name of the CloudWatch log group for VPC Flow Logs"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.flow_logs[0].name : null
}

output "cloudwatch_log_group_arn" {
  description = "ARN of the CloudWatch log group for VPC Flow Logs"
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.flow_logs[0].arn : null
}

