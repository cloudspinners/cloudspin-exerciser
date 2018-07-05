
variable "region" { default = "eu-west-1" }
variable "component" {}
variable "estate" {}
variable "api_users" { type = "list" }
variable "aws_profile" { default = "default" }
variable "pgp_key_for_secrets" {}
variable "assume_role_arn" { default = "" }
