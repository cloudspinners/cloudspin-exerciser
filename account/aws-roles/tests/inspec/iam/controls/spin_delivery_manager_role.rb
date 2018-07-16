# encoding: utf-8

title 'Spin Delivery Manager IAM role'

component = attribute('component', description: 'Which component things should be tagged')
configured_api_users = attribute('configured_api_users', description: 'IAM users defined for API access')

describe aws_iam_role_extended("spin_delivery_manager-#{component}") do
  it { should exist }
end

describe aws_iam_role_extended("spin_delivery_manager-#{component}").allowed_iam_user_names do
  it { should_not be_empty }
  it { should =~ configured_api_users.select { |username, user_configuration_from_yaml|
      user_configuration_from_yaml.key?('roles') && user_configuration_from_yaml['roles'].include?("spin_delivery_manager")
    }.map { |username, user_configuration_from_yaml| username }
  }
end

