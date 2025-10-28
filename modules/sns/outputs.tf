# Outputs for SNS Module

output "alerts_topic_arn" {
  description = "ARN of the alerts SNS topic"
  value       = aws_sns_topic.alerts.arn
}

output "alerts_topic_name" {
  description = "Name of the alerts SNS topic"
  value       = aws_sns_topic.alerts.name
}

output "notifications_topic_arn" {
  description = "ARN of the notifications SNS topic"
  value       = aws_sns_topic.notifications.arn
}

output "notifications_topic_name" {
  description = "Name of the notifications SNS topic"
  value       = aws_sns_topic.notifications.name
}

output "kms_key_id" {
  description = "ID of the KMS key for SNS encryption"
  value       = aws_kms_key.sns.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key for SNS encryption"
  value       = aws_kms_key.sns.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for SNS"
  value       = aws_cloudwatch_log_group.sns.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group for SNS"
  value       = aws_cloudwatch_log_group.sns.arn
}

