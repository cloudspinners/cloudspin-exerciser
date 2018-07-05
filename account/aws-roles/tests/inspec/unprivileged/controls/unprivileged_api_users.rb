# encoding: utf-8

title 'Unprivileged IAM users for API testing'

api_users = attribute('test_users', description: 'List of test user accounts expected')
component = attribute('component', description: 'Which component things should be tagged')
aws_profile = attribute('aws_profile', description: 'The aws_profile set in the component configuration')
assume_role_arn = attribute('assume_role_arn', description: 'The IAM role to assume for managing this stack')

describe aws_profile do
  it { should_not be_allowed_to_list_iam_roles(aws_profile).without_assuming_role }
  it { should be_allowed_to_list_iam_roles(aws_profile).by_assuming_role(assume_role_arn) }
end
