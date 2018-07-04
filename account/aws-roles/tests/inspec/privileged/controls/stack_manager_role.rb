# encoding: utf-8

title 'Stack Manager IAM role'

component = attribute('component', description: 'Which component things should be tagged')
estate = attribute('estate', description: 'Which estate things should be tagged')

describe aws_iam_role("stack_manager-#{component}-#{estate}") do
  it { should exist }
end
