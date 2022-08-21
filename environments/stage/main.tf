## Terraform Cloud ##

terraform {
  cloud {
    organization = "davidivad96"

    workspaces {
      name = "imagina-energia-stage"
    }
  }
}

## Modules ##

# VPC; Subnets; Route tables; Gateways

module "network" {
  source         = "../../modules/network"
  APP_NAME       = var.APP_NAME
  ENV            = var.ENV
  AWS_REGION     = var.AWS_REGION
  AWS_ACCOUNT_ID = var.AWS_ACCOUNT_ID
}

# AutoScaling Group, Target Group Load Balancer

module "scaling" {
  source                = "../../modules/scaling"
  APP_NAME              = var.APP_NAME
  ENV                   = var.ENV
  AWS_REGION            = var.AWS_REGION
  AWS_ACCOUNT_ID        = var.AWS_ACCOUNT_ID
  MAIN_VPC_ID           = module.network.main_vpc_id
  PUBLIC_SUBNETS_IDS    = module.network.public_subnets_ids
  ALB_SECURITY_GROUP_ID = module.security.alb_security_group_id
  ECS_CLUSTER_NAME      = module.containers.ecs_cluster_name
  ECS_SERVICE_NAME      = module.containers.ecs_service_name
}

# ECS

module "containers" {
  source                                 = "../../modules/containers"
  APP_NAME                               = var.APP_NAME
  ENV                                    = var.ENV
  AWS_REGION                             = var.AWS_REGION
  AWS_ACCOUNT_ID                         = var.AWS_ACCOUNT_ID
  TARGET_GROUP_ARN                       = module.scaling.ecs_target_group_arn
  PRIVATE_SUBNETS_IDS                    = module.network.private_subnets_ids
  ECS_SERVICE_SECURITY_GROUP_ID          = module.security.ecs_service_security_group_id
  ECS_TASK_DEFINITION_EXECUTION_ROLE_ARN = module.security.ecs_task_definition_execution_role_arn
  AURORA_DB_HOST                         = module.database.aurora_db_host
  AURORA_DB_PORT_NUMBER                  = module.database.aurora_db_port_number
  AURORA_DB_NAME                         = module.database.aurora_db_name
  AURORA_DB_USER                         = module.database.aurora_db_user
  AURORA_DB_PASSWORD                     = module.security.secrets_manager_db_password
}

# Security groups, IAM Roles and AWS WAF

module "security" {
  source         = "../../modules/security"
  APP_NAME       = var.APP_NAME
  ENV            = var.ENV
  AWS_REGION     = var.AWS_REGION
  AWS_ACCOUNT_ID = var.AWS_ACCOUNT_ID
  MAIN_VPC_ID    = module.network.main_vpc_id
  ALB_ARN        = module.scaling.alb_arn
}

# Aurora Database

module "database" {
  source              = "../../modules/database"
  APP_NAME            = var.APP_NAME
  ENV                 = var.ENV
  AWS_REGION          = var.AWS_REGION
  AWS_ACCOUNT_ID      = var.AWS_ACCOUNT_ID
  PRIVATE_SUBNETS_IDS = module.network.private_subnets_ids
  AURORA_DB_PASSWORD  = module.security.secrets_manager_db_password
}
