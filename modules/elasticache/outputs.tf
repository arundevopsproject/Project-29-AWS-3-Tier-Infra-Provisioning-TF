# Outputs for ElastiCache Module

output "replication_group_id" {
  description = "ID of the ElastiCache replication group"
  value       = aws_elasticache_replication_group.main.id
}

output "replication_group_arn" {
  description = "ARN of the ElastiCache replication group"
  value       = aws_elasticache_replication_group.main.arn
}

output "primary_endpoint" {
  description = "Primary endpoint of the Redis cluster"
  value       = aws_elasticache_replication_group.main.primary_endpoint_address
}

output "primary_port" {
  description = "Primary port of the Redis cluster"
  value       = aws_elasticache_replication_group.main.port
}

output "reader_endpoint" {
  description = "Reader endpoint of the Redis cluster"
  value       = aws_elasticache_replication_group.main.reader_endpoint_address
}

output "configuration_endpoint" {
  description = "Configuration endpoint of the Redis cluster"
  value       = aws_elasticache_replication_group.main.configuration_endpoint_address
}

output "subnet_group_name" {
  description = "Name of the ElastiCache subnet group"
  value       = aws_elasticache_subnet_group.main.name
}

output "parameter_group_name" {
  description = "Name of the ElastiCache parameter group"
  value       = aws_elasticache_parameter_group.main.name
}

output "log_group_name" {
  description = "Name of the CloudWatch log group for Redis slow logs"
  value       = aws_cloudwatch_log_group.redis_slow.name
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group for Redis slow logs"
  value       = aws_cloudwatch_log_group.redis_slow.arn
}

# Read Replica Outputs
output "read_replica_id" {
  description = "ID of the read replica replication group"
  value       = length(aws_elasticache_replication_group.read_replica) > 0 ? aws_elasticache_replication_group.read_replica[0].id : null
}

output "read_replica_arn" {
  description = "ARN of the read replica replication group"
  value       = length(aws_elasticache_replication_group.read_replica) > 0 ? aws_elasticache_replication_group.read_replica[0].arn : null
}

output "read_replica_primary_endpoint" {
  description = "Primary endpoint of the read replica cluster"
  value       = length(aws_elasticache_replication_group.read_replica) > 0 ? aws_elasticache_replication_group.read_replica[0].primary_endpoint_address : null
}

output "read_replica_reader_endpoint" {
  description = "Reader endpoint of the read replica cluster"
  value       = length(aws_elasticache_replication_group.read_replica) > 0 ? aws_elasticache_replication_group.read_replica[0].reader_endpoint_address : null
}

