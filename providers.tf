terraform {
  backend "s3" {
    bucket                  = "consolidated-remote-state"
    dynamodb_table          = "consolidated-remote-state-lock"
    encrypt                 = true
    workspace_key_prefix    = "environments"
    key                     = "oidc/tf-aws-github-oidc.tfstate"
    region                  = "ap-southeast-2"
    role_arn                = "arn:aws:iam::421348623741:role/terraform-state-role"
  }

  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.6.2"
    }
  }
}

provider "aws" {
  region = local.aws_region

  assume_role {
    duration = "1h" # or shorter!
    #role_arn = "arn:aws:iam::${var.aws_account_id}:role/PowerUser" # use the actual least-privilege role you want to use
    role_arn = "${var.workspace_iam_roles[terraform.workspace]}"
  }
  default_tags {
    tags = local.common_tags
  }
}