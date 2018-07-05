# encoding: utf-8

title 'Component Administrator IAM role'

component = attribute('component', description: 'Which component things should be tagged')

describe aws_iam_role("component_administrator-#{component}") do
  it { should exist }
end
