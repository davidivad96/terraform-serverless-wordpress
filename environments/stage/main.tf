## Terraform Cloud ##

terraform {
  backend "local" {
    path = "terraform.tfstate"
  }
}

## Modules ##

# VPC, Subnets, Route Tables and Gateways

module "network" {
  source     = "../../modules/network"
  APP_NAME   = var.APP_NAME
  ENV        = var.ENV
  AWS_REGION = var.AWS_REGION
}

# AutoScaling Group, Target Group Load Balancer

module "scaling" {
  source                = "../../modules/scaling"
  APP_NAME              = var.APP_NAME
  ENV                   = var.ENV
  AWS_REGION            = var.AWS_REGION
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
  TARGET_GROUP_ARN                       = module.scaling.ecs_target_group_arn
  PRIVATE_SUBNETS_IDS                    = module.network.private_subnets_ids
  ECS_SERVICE_SECURITY_GROUP_ID          = module.security.ecs_service_security_group_id
  ECS_TASK_DEFINITION_EXECUTION_ROLE_ARN = module.security.ecs_task_definition_execution_role_arn
  AURORA_CLUSTER                         = module.database.aurora_cluster
  AURORA_CLUSTER_PASSWORD                = module.security.secrets_manager_aurora_password
  EFS_FILE_SYSTEM                        = module.storage.efs_file_system
  EFS_FILE_SYSTEM_ACCESS_POINT           = module.storage.efs_file_system_access_point
}

# Security groups, IAM Roles and AWS WAF

module "security" {
  source      = "../../modules/security"
  APP_NAME    = var.APP_NAME
  ENV         = var.ENV
  AWS_REGION  = var.AWS_REGION
  MAIN_VPC_ID = module.network.main_vpc_id
  ALB_ARN     = module.scaling.alb_arn
}

# Aurora Database

module "database" {
  source                   = "../../modules/database"
  APP_NAME                 = var.APP_NAME
  ENV                      = var.ENV
  AWS_REGION               = var.AWS_REGION
  PRIVATE_SUBNETS_IDS      = module.network.private_subnets_ids
  AURORA_CLUSTER_PASSWORD  = module.security.secrets_manager_aurora_password
  AURORA_SECURITY_GROUP_ID = module.security.aurora_security_group_id
}

# EFS

module "storage" {
  source                              = "../../modules/storage"
  APP_NAME                            = var.APP_NAME
  ENV                                 = var.ENV
  AWS_REGION                          = var.AWS_REGION
  PRIVATE_SUBNETS_IDS                 = module.network.private_subnets_ids
  EFS_MOUNT_TARGETS_SECURITY_GROUP_ID = module.security.efs_mount_targets_security_group_id
}
