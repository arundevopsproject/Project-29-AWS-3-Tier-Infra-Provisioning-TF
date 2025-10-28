# Outputs for WAF Module

output "waf_web_acl_id" {
  description = "ID of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.id
}

output "waf_web_acl_arn" {
  description = "ARN of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.arn
}

output "waf_web_acl_name" {
  description = "Name of the WAF Web ACL"
  value       = aws_wafv2_web_acl.main.name
}

output "waf_association_id" {
  description = "ID of the WAF association"
  value       = aws_wafv2_web_acl_association.main.id
}

output "waf_log_group_name" {
  description = "Name of the WAF CloudWatch log group"
  value       = aws_cloudwatch_log_group.waf.name
}

output "waf_log_group_arn" {
  description = "ARN of the WAF CloudWatch log group"
  value       = aws_cloudwatch_log_group.waf.arn
}

output "ip_set_arn" {
  description = "ARN of the IP set (if created)"
  value       = length(aws_wafv2_ip_set.whitelist) > 0 ? aws_wafv2_ip_set.whitelist[0].arn : null
}

