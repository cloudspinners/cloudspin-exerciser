require 'yaml'
require 'rspec/expectations'

RSpec::Matchers.define :have_api_key_configured do |test_user_api_keys|
  match do |user|
    user_credentials = test_user_api_keys[user.username]
    ! user_credentials.nil? &&
        ! user_credentials['access_key_id'].to_s.empty? &&
        ! user_credentials['secret_access_key'].to_s.empty?
  end
  failure_message do |user|
    "expected the component configuration to include:\ntest_user_api_keys:\n\t#{user.username}:\n\t\taccess_key_id: <key value>"
  end
  description do
    "have an API key configured"
  end

  def has_access_keys?
    ! ( @api_access_key_id.nil? || @api_secret_access_key.nil? )
  end
end
