variable "APP_NAME" {}

variable "ENV" {}

variable "AWS_REGION" {}

variable "AWS_ACCOUNT_ID" {}

variable "PRIVATE_SUBNETS_IDS" {}

variable "AURORA_DB_PASSWORD" {}

variable "DB_AVAILABILITY_ZONES" {
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
