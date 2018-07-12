# encoding: utf-8

title 'Spin Stack Manager IAM role'

component = attribute('component', description: 'Which component things should be tagged')
configured_api_users = attribute('configured_api_users', description: 'IAM users defined for API access')

describe aws_iam_role_extended("spin_stack_manager-#{component}") do
  it { should exist }
end

describe aws_iam_role_extended("spin_stack_manager-#{component}").allowed_iam_user_names do
  it { should_not be_empty }
  it { should =~ configured_api_users.select { |username, user_info|
      user_info.key?('roles') && user_info['roles'].include?("spin_stack_manager-#{component}")
    }.map { |username, user_info| username }
  }
end
