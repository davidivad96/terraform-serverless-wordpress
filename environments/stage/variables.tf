variable "APP_NAME" {
  default = "serverless-wordpress"
}

variable "ENV" {
  default = "stage"
}

variable "AWS_REGION" {
  default     = "us-east-1"
  description = "US East (Northern Virginia) Region"
}

variable "AWS_ACCOUNT_ID" {
  default     = "222172367795"
  description = "AWS Account ID"
}

variable "AWS_ACCESS_KEY_ID" {
  default = ""
}

variable "AWS_SECRET_ACCESS_KEY" {
  default = ""
}
