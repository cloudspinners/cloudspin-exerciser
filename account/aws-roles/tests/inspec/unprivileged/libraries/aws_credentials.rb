require 'yaml'
require 'rspec/expectations'


RSpec::Matchers.define :be_allowed_to_list_iam_roles do |aws_profile|

  match do
    iam_client.list_roles({})
  end

  chain(:without_assuming_role) do
    @credentials = aws_profile_credentials(aws_profile)
  end

  chain(:by_assuming_role) do |role_arn|
    @credentials = assume_role_credentials(aws_profile, role_arn)
  end

  match_when_negated do
    begin
      iam_client.list_roles({})
    rescue Aws::IAM::Errors::AccessDenied
      true
    else
      false
    end
  end

  def credentials
    @credentials ||= aws_profile_credentials(aws_profile)
  end

  def iam_client
    Aws::IAM::Client.new(
      region: 'eu-west-1',
      credentials: credentials
    )
  end

  def aws_profile_credentials(aws_profile)
    Aws::SharedCredentials.new(profile_name: aws_profile)
  end

  def assume_role_credentials(aws_profile, role_arn)
    Aws::AssumeRoleCredentials.new(
      client: sts_client(aws_profile),
      role_arn: role_arn,
      role_session_name: "inspec-session"
    )
  end

  def sts_client(aws_profile)
    Aws::STS::Client.new(
      region: 'eu-west-1',
      credentials: aws_profile_credentials(aws_profile)
    )
  end

  failure_message do |aws_profile|
    "be allowed to list IAM roles using aws credentials profile '#{aws_profile}'"
  end

  description do
    "be allowed to list IAM roles using aws credentials profile '#{aws_profile}'"
  end

end

