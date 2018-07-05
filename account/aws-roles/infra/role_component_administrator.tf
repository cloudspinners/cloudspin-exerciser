
output "component_administrator_role_arn" {
  value = "${aws_iam_role.component_administrator.arn}"
}

# This role can be assumed by the specified user(s)
resource "aws_iam_role" "component_administrator" {
  name = "component_administrator-${var.component}"
  description = "Can create and destroy IAM resources in ${var.component} stacks"

  assume_role_policy = <<END_ASSUME_ROLE_POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": [ "${join("\",\"", aws_iam_user.api_user.*.arn)}" ]
      }
    }
  ]
}
END_ASSUME_ROLE_POLICY
}

resource "aws_iam_role_policy_attachment" "attach_sysadmin_policy_to_role" {
  role       = "${aws_iam_role.component_administrator.name}"
  policy_arn = "arn:aws:iam::aws:policy/job-function/SystemAdministrator"
}

resource "aws_iam_role_policy_attachment" "attach_parameter_policy_to_administrator_role" {
  role       = "${aws_iam_role.component_administrator.name}"
  policy_arn = "${aws_iam_policy.rights_for_ssm_parameters.arn}"
}

