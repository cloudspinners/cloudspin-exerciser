# encoding: utf-8

title 'IAM users created to run cloudspin'

component = attribute('component', description: 'Which component things should be tagged')
api_users = attribute('api_users', description: 'IAM users defined for API access')

api_users.each { |username, user_details|
  describe aws_iam_user(username: username) do
    it { should exist }
    it { should_not have_console_password }
    it 'has access keys' do
      expect(described_class.access_keys).to_not be_empty
    end
  end
}

