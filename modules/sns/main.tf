# SNS Module - Creates SNS topics for notifications

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  kms_master_key_id = aws_kms_key.sns.arn

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alerts"
  })
}

# SNS Topic for General Notifications
resource "aws_sns_topic" "notifications" {
  name = "${var.project_name}-${var.environment}-notifications"

  kms_master_key_id = aws_kms_key.sns.arn

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-notifications"
  })
}

# KMS Key for SNS encryption
resource "aws_kms_key" "sns" {
  description             = "KMS key for SNS encryption"
  deletion_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-sns-kms-key"
  })
}

# KMS Key Alias
resource "aws_kms_alias" "sns" {
  name          = "alias/${var.project_name}-${var.environment}-sns"
  target_key_id = aws_kms_key.sns.key_id
}

# SNS Topic Policy for Alerts
resource "aws_sns_topic_policy" "alerts" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "cloudwatch.amazonaws.com",
            "s3.amazonaws.com",
            "rds.amazonaws.com",
            "elasticache.amazonaws.com",
            "wafv2.amazonaws.com"
          ]
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}

# SNS Topic Policy for Notifications
resource "aws_sns_topic_policy" "notifications" {
  arn = aws_sns_topic.notifications.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = [
            "cloudwatch.amazonaws.com",
            "s3.amazonaws.com",
            "rds.amazonaws.com",
            "elasticache.amazonaws.com",
            "wafv2.amazonaws.com"
          ]
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.notifications.arn
      }
    ]
  })
}

# Email Subscriptions for Alerts
resource "aws_sns_topic_subscription" "alerts_email" {
  count = length(var.alert_email_addresses)

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email_addresses[count.index]
}

# SMS Subscriptions for Critical Alerts
resource "aws_sns_topic_subscription" "alerts_sms" {
  count = length(var.alert_sms_numbers)

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "sms"
  endpoint  = var.alert_sms_numbers[count.index]
}

# Email Subscriptions for Notifications
resource "aws_sns_topic_subscription" "notifications_email" {
  count = length(var.notification_email_addresses)

  topic_arn = aws_sns_topic.notifications.arn
  protocol  = "email"
  endpoint  = var.notification_email_addresses[count.index]
}

# Lambda Subscription for Alerts (optional)
resource "aws_sns_topic_subscription" "alerts_lambda" {
  count = var.lambda_function_arn != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "lambda"
  endpoint  = var.lambda_function_arn
}

# SQS Subscription for Alerts (optional)
resource "aws_sns_topic_subscription" "alerts_sqs" {
  count = var.sqs_queue_arn != "" ? 1 : 0

  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "sqs"
  endpoint  = var.sqs_queue_arn
}

# CloudWatch Log Group for SNS
resource "aws_cloudwatch_log_group" "sns" {
  name              = "/aws/sns/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-sns-logs"
  })
}

# CloudWatch Alarms for SNS
resource "aws_cloudwatch_metric_alarm" "sns_delivery_failures" {
  alarm_name          = "${var.project_name}-${var.environment}-sns-delivery-failures"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "NumberOfNotificationsFailed"
  namespace           = "AWS/SNS"
  period              = "300"
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "This metric monitors SNS delivery failures"
  alarm_actions       = [aws_sns_topic.alerts.arn]

  dimensions = {
    TopicName = aws_sns_topic.alerts.name
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-sns-delivery-failures"
  })
}

