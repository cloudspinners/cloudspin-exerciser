# encoding: utf-8

title 'API users'

api_users = attribute('test_users', description: 'List of test user accounts expected')
component = attribute('component', description: 'Which component things should be tagged')
estate = attribute('estate', description: 'Which estate things should be tagged')

api_users.each { |base_username|
  describe aws_iam_user(username: "api_user-#{component}-#{estate}-#{base_username}") do
    it { should exist }
  end
}
