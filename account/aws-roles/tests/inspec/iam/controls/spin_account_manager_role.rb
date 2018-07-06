# encoding: utf-8

title 'Spin Account Manager IAM role'

component = attribute('component', description: 'Which component things should be tagged')

describe aws_iam_role_extended("spin_account_manager-#{component}") do
  it { should exist }
end

# policy_struct = aws_iam_policy("spin_stack_manager-#{component}").policy

# describe "spin_stack_manager-#{component} policy" do
#   subject { policy_struct['Principle'].first['Condition'] }
#   it { should include 'NotIpAddress' }
# end