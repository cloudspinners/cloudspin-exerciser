provider "aws" {
  region = "${var.region}"
  profile = "${var.aws_profile_for_bootstrap}"
}
