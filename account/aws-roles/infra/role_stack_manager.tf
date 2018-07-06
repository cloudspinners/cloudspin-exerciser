
output "spin_stack_manager_role_arn" {
  value = "${aws_iam_role.spin_stack_manager.arn}"
}

# This role can be assumed by the specified user(s)
resource "aws_iam_role" "spin_stack_manager" {
  name = "spin_stack_manager-${var.component}"
  description = "Can create and destroy ${var.component} stacks"

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

resource "aws_iam_role_policy_attachment" "attach_poweruser_policy_to_stack_manager_role" {
  role       = "${aws_iam_role.spin_stack_manager.name}"
  policy_arn = "arn:aws:iam::aws:policy/PowerUserAccess"
}

resource "aws_iam_role_policy_attachment" "attach_parameter_policy_to_stack_manager_role" {
  role       = "${aws_iam_role.spin_stack_manager.name}"
  policy_arn = "${aws_iam_policy.rights_for_ssm_parameters.arn}"
}

