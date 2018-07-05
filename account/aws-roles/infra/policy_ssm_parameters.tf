
resource "aws_iam_policy" "rights_for_ssm_parameters" {
    name        = "ssm-paramater-access-for-${var.component}"
    description = "Can get and put parameters for ${var.component}"
    policy = <<END_POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ssm:DescribeParameters",
        "ssm:GetParameter",
        "ssm:GetParameters",
        "ssm:GetParametersByPath",
        "ssm:PutParameter",
        "ssm:AddTagsToResource"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
END_POLICY
}
