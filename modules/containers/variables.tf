variable "APP_NAME" {}

variable "ENV" {}

variable "AWS_REGION" {}

variable "TARGET_GROUP_ARN" {}

variable "PRIVATE_SUBNETS_IDS" {}

variable "ECS_SERVICE_SECURITY_GROUP_ID" {}

variable "ECS_TASK_DEFINITION_EXECUTION_ROLE_ARN" {}

variable "AURORA_CLUSTER" {}

variable "AURORA_CLUSTER_PASSWORD" {}

variable "EFS_FILE_SYSTEM" {}

variable "ECS_TASK_DEFINITION_CPU" {
  default = 512
}

variable "ECS_TASK_DEFINITION_MEMORY" {
  default = 1024
}
