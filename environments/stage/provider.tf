provider "aws" {
  region              = var.AWS_REGION
  allowed_account_ids = [var.AWS_ACCOUNT_ID]
}
