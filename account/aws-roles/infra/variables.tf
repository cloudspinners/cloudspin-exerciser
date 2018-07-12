
variable "region" { default = "eu-west-1" }
variable "component" {}
variable "estate" {}

variable "spin_api_users" {
  type = "list"
  default = []
}
variable "spin_account_manager-users" {
  type = "list"
  default = []
}
variable "spin_stack_manager-users" {
  type = "list"
  default = []
}

variable "aws_profile" { default = "default" }
variable "pgp_key_for_secrets" {}
variable "assume_role_arn" { default = "" }

