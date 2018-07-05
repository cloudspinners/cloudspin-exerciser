# encoding: utf-8

title 'Validate that the profiles and users are set up to assume-role as expected'

aws_profile = attribute('aws_profile', description: 'The aws_profile set in the component configuration')
assume_role_arn = attribute('assume_role_arn', description: 'The IAM role to assume for managing this stack')

describe aws_profile do
  it { should_not be_allowed_to_list_iam_roles(aws_profile).without_assuming_role }
  it { should be_allowed_to_list_iam_roles(aws_profile).by_assuming_role(assume_role_arn) }
end
