# encoding: utf-8

title 'Spin Stack Manager IAM role'

component = attribute('component', description: 'Which component things should be tagged')

describe aws_iam_role_extended("spin_stack_manager-#{component}") do
  it { should exist }
end

describe aws_iam_role_extended("spin_stack_manager-#{component}").allowed_users do
  it { should_not be_empty }
end
