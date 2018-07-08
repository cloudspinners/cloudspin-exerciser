class AwsIamRoleExtended < Inspec.resource(1)
  name 'aws_iam_role_extended'
  desc 'Verifies extended settings for an IAM Role'
  example "
    describe aws_iam_role_extended('my_role') do
      it { should_not be_empty }
    end
  "
  supports platform: 'aws'

  include AwsSingularResourceMixin
  attr_reader :description, :role_name, :arn, :assume_role_policy, :max_session_duration

  def allowed_iam_user_arns
    extract_principal_arns
  end

  def allowed_iam_user_names
    extract_principal_arns.map { |arn|
      arn.gsub(/^.+\//, '')
    }
  end

  def extract_principal_arns
    @assume_role_policy['Statement'].map { |statement|
      if statement.key?('Principal')
        if statement['Principal'].key?('AWS')
          statement['Principal']['AWS']
        end
      end
    }.flatten
  end

  def to_s
    "IAM Role Extended #{role_name}"
  end

  private

  def validate_params(raw_params)
    validated_params = check_resource_param_names(
      raw_params: raw_params,
      allowed_params: [:role_name],
      allowed_scalar_name: :role_name,
      allowed_scalar_type: String,
    )
    if validated_params.empty?
      raise ArgumentError, 'You must provide a role_name to aws_iam_role.'
    end
    validated_params
  end

  def fetch_from_api
    role_info = nil
    begin
      role_info = BackendFactory.create(inspec_runner).get_role(role_name: role_name)
    rescue Aws::IAM::Errors::NoSuchEntity
      @exists = false
      return
    end
    @exists = true
    @description = role_info.role.description
    @arn = role_info.role.arn
    @assume_role_policy = JSON.parse(URI.decode(role_info.role.assume_role_policy_document))
    @max_session_duration = role_info.role.max_session_duration
  end

  # Uses the SDK API to really talk to AWS
  class Backend
    class AwsClientApi < AwsBackendBase
      BackendFactory.set_default_backend(self)
      self.aws_client_class = Aws::IAM::Client
      def get_role(query)
        aws_service_client.get_role(query)
      end
    end
  end
end
