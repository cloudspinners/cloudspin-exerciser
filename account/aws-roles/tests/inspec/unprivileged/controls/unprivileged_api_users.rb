# encoding: utf-8

title 'Unprivileged IAM users for API testing'

api_users = attribute('test_users', description: 'List of test user accounts expected')
component = attribute('component', description: 'Which component things should be tagged')
estate = attribute('estate', description: 'Which estate things should be tagged')
test_user_api_keys = attribute('test_user_api_keys', description: 'The API keys configured at the component level')

# api_users.each { |base_username|
  # username = "api_user-#{component}-#{estate}-#{base_username}"
  unprivileged_creds = test_user_api_keys['unprivileged_user']
  describe 'unprivileged_user' do
    it { should_not be_allowed_to_list_iam_roles_with(unprivileged_creds) }
  end

  privileged_creds = test_user_api_keys['privileged_user']
  describe 'privileged_user' do
    it { should be_allowed_to_list_iam_roles_with(privileged_creds) }
 end


# }
