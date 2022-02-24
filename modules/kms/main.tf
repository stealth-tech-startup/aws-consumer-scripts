terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

variable "kms_key_alias_name" {}

data "template_file" "kms_policy" {
  template = templatefile("${path.root}/policies/kms_policy.tmpl", {
    aws_region = data.aws_region.current.name
    aws_account_id = data.aws_caller_identity.current.account_id
  })
}

resource "aws_kms_key" "sd_build_kms_key" {
  description = "KSM Key for Screwdriver Builds"
  enable_key_rotation = true
  policy = data.template_file.kms_policy.rendered
}

resource "aws_kms_alias" "sd_build_kms_key_alias" {
  name          = "alias/${var.kms_key_alias_name}"
  target_key_id = aws_kms_key.sd_build_kms_key.key_id
}