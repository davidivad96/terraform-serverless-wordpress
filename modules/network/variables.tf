variable "APP_NAME" {}

variable "ENV" {}

variable "AWS_REGION" {}

variable "AWS_ACCOUNT_ID" {}

variable "SUBNETS" {
  default = {
    "a" = [0, 16]
    "b" = [32, 48]
  }
}
