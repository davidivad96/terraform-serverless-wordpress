// ALB Security Group

resource "aws_security_group" "alb_security_group" {
  name        = "alb-security-group"
  description = "ALB Security Group"
  vpc_id      = var.MAIN_VPC_ID
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name     = "alb-security-group"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

// ECS Service Security Group

resource "aws_security_group" "ecs_service_security_group" {
  name        = "ecs-service-security-group"
  description = "ECS Service Security Group"
  vpc_id      = var.MAIN_VPC_ID
  ingress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    security_groups = [aws_security_group.alb_security_group.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name     = "ecs-service-security-group"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

// Aurora Database Security Group

resource "aws_security_group" "aurora_security_group" {
  name        = "aurora-security-group"
  description = "Aurora Database Security Group"
  vpc_id      = var.MAIN_VPC_ID
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service_security_group.id]
  }
  tags = {
    Name     = "aurora-security-group"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

// EFS Mount Targets Security Group

resource "aws_security_group" "efs_mount_targets_security_group" {
  name        = "efs-mount-targets-security-group"
  description = "EFS Mount Targets Security Group"
  vpc_id      = var.MAIN_VPC_ID
  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service_security_group.id]
  }
  tags = {
    Name     = "efs-mount-targets-security-group"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

// ECS Task Definition Execution Role

resource "aws_iam_role" "ecs_task_definition_execution_role" {
  name = "ecs-task-definition-execution-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
  tags = {
    Name     = "ecs-task-definition-execution-role"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

resource "aws_iam_policy" "ecs_task_definition_execution_policy" {
  name = "ecs-task-definition-execution-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:*"]
      Resource = "*"
    }],
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_definition_execution_role_policy_attachment" {
  role       = aws_iam_role.ecs_task_definition_execution_role.name
  policy_arn = aws_iam_policy.ecs_task_definition_execution_policy.arn
}

// Web Application Firewall

resource "aws_wafv2_web_acl" "web_acl" {
  name        = "web-acl"
  description = "WEB ACL for Wordpress site"
  scope       = "REGIONAL"
  default_action {
    allow {}
  }
  rule {
    name     = "AWS-AWSManagedRulesSQLiRuleSet"
    priority = 10
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesSQLiRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesWordPressRuleSet"
    priority = 20
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesWordPressRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesWordPressRuleSet"
      sampled_requests_enabled   = true
    }
  }
  rule {
    name     = "AWS-AWSManagedRulesPHPRuleSet"
    priority = 30
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesPHPRuleSet"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWS-AWSManagedRulesPHPRuleSet"
      sampled_requests_enabled   = true
    }
  }
  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "MetricForWordpressACL"
    sampled_requests_enabled   = true
  }
  tags = {
    Name     = "web-acl"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

resource "aws_wafv2_web_acl_association" "web_acl_association" {
  web_acl_arn  = aws_wafv2_web_acl.web_acl.arn
  resource_arn = var.ALB_ARN
}

resource "aws_cloudwatch_log_group" "web_acl_log_group" {
  name = "aws-waf-logs-group"
  tags = {
    Name     = "aws-waf-logs-group"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

resource "aws_wafv2_web_acl_logging_configuration" "web_acl_logging_configuration" {
  log_destination_configs = [aws_cloudwatch_log_group.web_acl_log_group.arn]
  resource_arn            = aws_wafv2_web_acl.web_acl.arn
}

// Database password stored in Secrets Manager

resource "random_password" "master_password" {
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "aurora_password" {
  name        = "aurora-password-2"
  description = "Database password"
  tags = {
    Name     = "aurora-password-2"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

resource "aws_secretsmanager_secret_version" "aurora_password_version" {
  secret_id     = aws_secretsmanager_secret.aurora_password.id
  secret_string = random_password.master_password.result
}
