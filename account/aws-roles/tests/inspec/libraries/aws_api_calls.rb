require 'yaml'
require 'rspec/expectations'

# # RSpec::Matchers.define :be_able_to_call do |api_call|
# RSpec::Matchers.define :be_able_to_call do
#   match do |user|
#     puts "KSM: USER: '#{user}'"
#     # puts "KSM: Policies: #{backend.list_user_policies}"
#     # puts "KSM: Attached Policies: #{backend.list_attached_user_policies}"
#     true
#   end
# end

RSpec::Matchers.define :can_list_vpcs do
  match do |user|
    puts "KSM: USER: '#{user}'"
    # puts "KSM: Policies: #{backend.list_user_policies}"
    # puts "KSM: Attached Policies: #{backend.list_attached_user_policies}"
    true
  end
end


RSpec::Matchers.define :have_api_key_configured do |test_user_api_keys|
  match do |user|
    credentials = credentials_for_user(user.username)
    (!credentials.nil?) && credentials.has_access_keys?
  end
  failure_message do |user|
    "expected a component configuration entry:\ntest_user_api_keys:\n\t#{user.username}:\n\t\taccess_key_id: <key value>"
  end
  description do
    "have an API key configured"
  end
end

def credentials_for_user(username)
    Cloudspin::AwsCredentials.new(test_user_api_keys[username])
end

module Cloudspin
  class AwsCredentials
    def intialize(credentials_hash)
      @api_access_key_id = credentials_hash['access_key_id']
      @api_secret_access_key = credentials_hash['secret_access_key']
    end

    def has_access_keys?
      ! ( @api_access_key_id.nil? || @api_secret_access_key.nil? )
    end
  end
end

# def class ApiTrier

#   attr_reader :cient

#   def intialize
#     @client = Aws::EC2::Client.new(
#       region: 'eu-west-1'
#       # credentials: credentials
#     )
#   end

#   def describe_vpcs
#     client.describe_vpcs({})
#   end

#   def client
#     Aws::EC2::Client.new(
#       region: region_name,
#       credentials: credentials,
#     )
#   end
# end

