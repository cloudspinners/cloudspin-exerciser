# encoding: utf-8

title 'Stack Manager IAM role'

component = attribute('component', description: 'Which component things should be tagged')

describe aws_iam_role("stack_manager-#{component}") do
  it { should exist }
end
