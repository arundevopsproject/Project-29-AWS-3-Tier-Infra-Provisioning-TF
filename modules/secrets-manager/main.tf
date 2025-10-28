# Secrets Manager Module - Creates secure secrets storage

# KMS Key for Secrets Manager encryption
resource "aws_kms_key" "secrets" {
  description             = "KMS key for Secrets Manager encryption"
  deletion_window_in_days = 7

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow Secrets Manager to use the key"
        Effect = "Allow"
        Principal = {
          Service = "secretsmanager.amazonaws.com"
        }
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-secrets-kms-key"
  })
}

# KMS Key Alias
resource "aws_kms_alias" "secrets" {
  name          = "alias/${var.project_name}-${var.environment}-secrets"
  target_key_id = aws_kms_key.secrets.key_id
}

# Database Password Secret
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "${var.project_name}/${var.environment}/db-password"
  description             = "Database password for ${var.project_name} ${var.environment}"
  kms_key_id             = aws_kms_key.secrets.arn
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-db-password"
  })
}

# Database Password Secret Version
resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id = aws_secretsmanager_secret.db_password.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    engine   = "mysql"
    host     = var.db_endpoint
    port     = 3306
    dbname   = var.db_name
  })
}

# Redis Auth Token Secret
resource "aws_secretsmanager_secret" "redis_auth_token" {
  count = var.redis_auth_token != "" ? 1 : 0

  name                    = "${var.project_name}/${var.environment}/redis-auth-token"
  description             = "Redis auth token for ${var.project_name} ${var.environment}"
  kms_key_id             = aws_kms_key.secrets.arn
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-redis-auth-token"
  })
}

# Redis Auth Token Secret Version
resource "aws_secretsmanager_secret_version" "redis_auth_token" {
  count = var.redis_auth_token != "" ? 1 : 0

  secret_id = aws_secretsmanager_secret.redis_auth_token[0].id
  secret_string = jsonencode({
    auth_token = var.redis_auth_token
    endpoint   = var.redis_endpoint
    port       = 6379
  })
}

# Application Secrets
resource "aws_secretsmanager_secret" "app_secrets" {
  name                    = "${var.project_name}/${var.environment}/app-secrets"
  description             = "Application secrets for ${var.project_name} ${var.environment}"
  kms_key_id             = aws_kms_key.secrets.arn
  recovery_window_in_days = 7

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-app-secrets"
  })
}

# Application Secrets Version
resource "aws_secretsmanager_secret_version" "app_secrets" {
  secret_id = aws_secretsmanager_secret.app_secrets.id
  secret_string = jsonencode({
    jwt_secret     = var.jwt_secret
    api_key        = var.api_key
    encryption_key = var.encryption_key
    environment    = var.environment
  })
}

# IAM Policy for EC2 instances to access secrets
resource "aws_iam_policy" "secrets_access" {
  name        = "${var.project_name}-${var.environment}-secrets-access"
  description = "Policy for EC2 instances to access secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = [
          aws_secretsmanager_secret.db_password.arn,
          aws_secretsmanager_secret.app_secrets.arn
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kms:Decrypt"
        ]
        Resource = aws_kms_key.secrets.arn
      }
    ]
  })

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-secrets-access"
  })
}

# CloudWatch Log Group for Secrets Manager
resource "aws_cloudwatch_log_group" "secrets" {
  name              = "/aws/secretsmanager/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-secrets-logs"
  })
}

# CloudWatch Alarms for Secrets Manager
resource "aws_cloudwatch_metric_alarm" "secrets_rotation_failed" {
  alarm_name          = "${var.project_name}-${var.environment}-secrets-rotation-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "SecretRotationFailed"
  namespace           = "AWS/SecretsManager"
  period              = "300"
  statistic           = "Sum"
  threshold           = "0"
  alarm_description   = "This metric monitors failed secret rotations"
  alarm_actions       = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []

  dimensions = {
    SecretId = aws_secretsmanager_secret.db_password.id
  }

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-secrets-rotation-failed"
  })
}

# Data source for current AWS account
data "aws_caller_identity" "current" {}

