# encoding: utf-8

title 'IAM users for API testing'

api_users = attribute('test_users', description: 'List of test user accounts expected')
component = attribute('component', description: 'Which component things should be tagged')
estate = attribute('estate', description: 'Which estate things should be tagged')
test_user_api_keys = attribute('test_user_api_keys', description: 'The API keys configured at the component level')


api_users.each { |base_username|
  describe aws_iam_user(username: "api_user-#{component}-#{estate}-#{base_username}") do
    it { should exist }
    it { should_not have_console_password }
    it { is_expected.to have_api_key_configured(test_user_api_keys) }
  end
}
