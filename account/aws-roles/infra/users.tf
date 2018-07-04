
variable "test_users" { type = "list" }

resource "aws_iam_user" "api_test_user" {
  count = "${length(var.test_users)}"
  name = "api_user-${var.component}-${var.estate}-${var.test_users[count.index]}"
  path = "/user/"
}

resource "aws_iam_group" "api_users" {
  name = "api_users-${var.component}-${var.estate}"
}

resource "aws_iam_group_membership" "api_users" {
  name = "api_user-membership-${var.component}-${var.estate}"
  users = [ "${aws_iam_user.api_test_user.*.name}" ]
  group = "${aws_iam_group.api_users.name}"
}

resource "aws_iam_group_policy" "rights_to_assume_role" {
  name  = "rights_to_assume_role-${var.component}-${var.estate}"
  group = "${aws_iam_group.api_users.id}"
  policy = <<ENDOFPOLICY
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [ "iam:GetUser", "iam:GetRole" ],
    "Resource": "*"
  }
}
ENDOFPOLICY
}

# resource "aws_iam_role_policy_attachment" "attach_assume_role_policy_to_user" {
#   count = "${length(var.test_users)}"
#   role       = "${aws_iam_role.api_test_user.name}"
#   policy_arn = "${aws_iam_policy.rights_to_assume_role.arn}"
# }

resource "aws_iam_access_key" "api_test_user" {
  count = "${length(var.test_users)}"
  user    = "${aws_iam_user.api_test_user.*.name[count.index]}"
  pgp_key = "${var.pgp_key_for_secrets}"
}

output "api_test_user_arn" {
  value = ["${aws_iam_user.api_test_user.*.arn}"]
}

# output "api_test_user_secret" {
#   value = "${aws_iam_access_key.api_test_user.encrypted_secret}"
# }
