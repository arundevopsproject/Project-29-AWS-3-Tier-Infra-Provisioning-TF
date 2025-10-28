# Outputs for Secrets Manager Module

output "db_password_secret_arn" {
  description = "ARN of the database password secret"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "db_password_secret_name" {
  description = "Name of the database password secret"
  value       = aws_secretsmanager_secret.db_password.name
}

output "redis_auth_token_secret_arn" {
  description = "ARN of the Redis auth token secret"
  value       = length(aws_secretsmanager_secret.redis_auth_token) > 0 ? aws_secretsmanager_secret.redis_auth_token[0].arn : null
}

output "redis_auth_token_secret_name" {
  description = "Name of the Redis auth token secret"
  value       = length(aws_secretsmanager_secret.redis_auth_token) > 0 ? aws_secretsmanager_secret.redis_auth_token[0].name : null
}

output "app_secrets_arn" {
  description = "ARN of the application secrets"
  value       = aws_secretsmanager_secret.app_secrets.arn
}

output "app_secrets_name" {
  description = "Name of the application secrets"
  value       = aws_secretsmanager_secret.app_secrets.name
}

output "kms_key_id" {
  description = "ID of the KMS key for secrets encryption"
  value       = aws_kms_key.secrets.key_id
}

output "kms_key_arn" {
  description = "ARN of the KMS key for secrets encryption"
  value       = aws_kms_key.secrets.arn
}

output "secrets_access_policy_arn" {
  description = "ARN of the IAM policy for secrets access"
  value       = aws_iam_policy.secrets_access.arn
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for secrets"
  value       = aws_cloudwatch_log_group.secrets.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group for secrets"
  value       = aws_cloudwatch_log_group.secrets.arn
}

