# encoding: utf-8

title 'Spin Account Manager IAM role'

component = attribute('component', description: 'Which component things should be tagged')

describe aws_iam_role("spin_account_manager-#{component}") do
  it { should exist }
end
