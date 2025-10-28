# Outputs for RDS Module

output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.main.endpoint
  sensitive   = true
}

output "rds_port" {
  description = "RDS instance port"
  value       = aws_db_instance.main.port
}

output "rds_identifier" {
  description = "RDS instance identifier"
  value       = aws_db_instance.main.identifier
}

output "rds_arn" {
  description = "RDS instance ARN"
  value       = aws_db_instance.main.arn
}

output "rds_engine_version" {
  description = "RDS engine version"
  value       = aws_db_instance.main.engine_version
}

output "rds_instance_class" {
  description = "RDS instance class"
  value       = aws_db_instance.main.instance_class
}

output "rds_allocated_storage" {
  description = "RDS allocated storage"
  value       = aws_db_instance.main.allocated_storage
}

output "rds_multi_az" {
  description = "RDS Multi-AZ deployment"
  value       = aws_db_instance.main.multi_az
}

output "rds_backup_retention_period" {
  description = "RDS backup retention period"
  value       = aws_db_instance.main.backup_retention_period
}

output "rds_performance_insights_enabled" {
  description = "RDS Performance Insights enabled"
  value       = aws_db_instance.main.performance_insights_enabled
}

output "rds_enhanced_monitoring_enabled" {
  description = "RDS Enhanced Monitoring enabled"
  value       = aws_db_instance.main.monitoring_interval > 0
}

output "rds_kms_key_id" {
  description = "RDS KMS key ID"
  value       = aws_kms_key.rds.key_id
}

output "rds_kms_key_arn" {
  description = "RDS KMS key ARN"
  value       = aws_kms_key.rds.arn
}

output "read_replica_endpoint" {
  description = "RDS read replica endpoint"
  value       = length(aws_db_instance.read_replica) > 0 ? aws_db_instance.read_replica[0].endpoint : null
  sensitive   = true
}

output "read_replica_arn" {
  description = "RDS read replica ARN"
  value       = length(aws_db_instance.read_replica) > 0 ? aws_db_instance.read_replica[0].arn : null
}

output "db_password" {
  description = "Database password"
  value       = var.db_password != "" ? var.db_password : random_password.db_password.result
  sensitive   = true
}

