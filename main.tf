terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 4.0"
    }
  }

  cloud {
    organization = "your-organisation"

    workspaces {
      name = "your-workspace-name"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

module "s3_bucket_elb_logs" {
  source                      = "./module/s3_bucket_logs"
  ENV                         = var.ENV
  bucket_name                 = var.bucket_name
  account_number              = var.account_number
  bucket_rule_id              = var.bucket_rule_id
  bucket_rule_expiration_days = var.bucket_rule_expiration_days
  bucket_rule_prefix          = var.bucket_rule_prefix
}