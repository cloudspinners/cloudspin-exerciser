
variable "test_users" { type = "list" }

resource "aws_iam_user" "api_test_user" {
  count = "${length(var.test_users)}"
  name = "api_user-${var.component}-${var.estate}-${var.test_users[count.index]}"
  path = "/user/"
}

# {
#   "Version": "2012-10-17",
#   "Statement": {
#     "Effect": "Allow",
#     "Action": "sts:AssumeRole",
#     "Resource": "arn:aws:iam::ACCOUNT-ID-WITHOUT-HYPHENS:role/Test*"
#   }
# }

# resource "aws_iam_access_key" "api_test_user" {
#   count = "${length(var.test_users)}"
#   user    = "${aws_iam_user.api_test_user.name}"
#   pgp_key = "${var.pgp_key_api_test_user}"
# }

output "api_test_user_arn" {
  value = ["${aws_iam_user.api_test_user.*.arn}"]
}

# output "api_test_user_secret" {
#   value = "${aws_iam_access_key.api_test_user.encrypted_secret}"
# }
