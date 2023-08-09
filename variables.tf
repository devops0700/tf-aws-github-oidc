locals {
  # Default tags to be applied to all compatible resources
  common_tags = {
    ManagedBy = "Terraform"
    cost-center = "${terraform.workspace} Training and Research"
    Terraform   = "true"
    Environment = terraform.workspace
  }

  aws_region = var.region

  oidc_provider_arn = var.enabled ? (var.create_oidc_provider ? aws_iam_openid_connect_provider.github_actions[0].arn : data.aws_iam_openid_connect_provider.github_actions[0].arn) : ""
}

variable "region" {
    default = "ap-southeast-2"
}

variable "workspace_iam_roles" {
  default = {
    dev    = "arn:aws:iam::346285210400:role/PowerUser"
    nonprod = "arn:aws:iam::317603990568:role/PowerUser"
    prod = "arn:aws:iam::290363451905:role/PowerUser"
  }
}

variable "create_oidc_provider" {
  default     = true
  description = "Flag to enable/disable the creation of the GitHub OIDC provider."
  type        = bool
}

variable "enabled" {
  default     = true
  description = "Flag to enable/disable the creation of resources."
  type        = bool
}

variable "enterprise_slug" {
  default     = ""
  description = "Enterprise slug for GitHub Enterprise Cloud customers."
  type        = string
}