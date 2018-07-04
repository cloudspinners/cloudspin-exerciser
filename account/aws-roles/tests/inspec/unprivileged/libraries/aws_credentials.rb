require 'yaml'
require 'rspec/expectations'

RSpec::Matchers.define :be_allowed_to_list_iam_roles_with do |credentials|
  match do |username|
    iam_client(credentials).list_roles({})
  end

  failure_message do |credentials|
    "be allowed to list IAM roles using access_key_id '#{credentials['access_key_id']}'"
  end

  description do
    "be allowed to list IAM roles using access_key_id '#{credentials['access_key_id']}'"
  end

  match_when_negated do |username|
    begin
      iam_client(credentials).list_roles({})
    rescue Aws::IAM::Errors::AccessDenied
      true
    else
      false
    end

  end

  def iam_client(credentials)
    creds = Aws::Credentials.new(credentials['access_key_id'], credentials['secret_access_key'])
    Aws::IAM::Client.new(
      region: 'eu-west-1',
      credentials: creds
    )
  end

end

