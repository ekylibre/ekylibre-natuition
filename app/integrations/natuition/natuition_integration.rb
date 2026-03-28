module Natuition
  mattr_reader :default_options do
    {
      globals: {
        strip_namespaces: true,
        convert_response_tags_to: ->(tag) { tag.snakecase.to_sym },
        raise_errors: true
      },
      locals: {
        advanced_typecasting: true
      }
    }
  end

  class ServiceError < StandardError; end

  class NatuitionIntegration < ActionIntegration::Base

    BASE_URL = 'http://192.168.1.59:8080/api/v1/'.freeze

    authenticate_with :check do
      parameter :email
      parameter :password
      parameter :robot_serial_number
    end

    calls :retrieve_token, :customer_info, :robot_sessions, :robot_session

    # Get token with login and password
    # /api/v1/data_gathering/auth/login
    def retrieve_token
      integration = fetch
      payload = { email: integration.parameters['email'], hash_pwd: integration.parameters['password'] }
      post_json(BASE_URL + "data_gathering/auth/login", payload) do |r|
        r.success do
          list = JSON(r.body).deep_symbolize_keys
          r.error :api_down if r.body.include? 'Error'
        end
      end
    end

    # Check if the API is up
    def check(integration = nil)
      integration = fetch integration
      get_json(BASE_URL + "data_gathering/health_check") do |r|
        r.success do
          Rails.logger.info 'CHECKED'.green
          r.error :api_down if r.body.include? 'Error'
        end
      end
    end

    # /api/v1/data_gathering/customer/get_info
    def customer_info
      integration = fetch
      # Grab token
      token = JSON(retrieve_token.body).deep_symbolize_keys[:access_token]

      # Call API
      get_json(BASE_URL + "data_gathering/customer/get_info", 'Authorization' => "Bearer #{token}") do |r|
        r.success do
          list = JSON(r.body).deep_symbolize_keys
        end
      end
    end

    # /api/v1/data_gathering/customer/get_info
    def robot_sessions
      integration = fetch
      # Grab token
      token = JSON(retrieve_token.body).deep_symbolize_keys[:access_token]

      # Call API
      get_json(BASE_URL + "data_gathering/sessions_of_robot?robot_sn=#{integration.parameters['robot_serial_number']}", 'Authorization' => "Bearer #{token}") do |r|
        r.success do
          list = JSON(r.body).map(&:deep_symbolize_keys)
        end
      end
    end

    # /api/v1/data_gathering/get_report_data
    def robot_session(id)
      integration = fetch
      # Grab token
      token = JSON(retrieve_token.body).deep_symbolize_keys[:access_token]

      # Call API
      get_json(BASE_URL + "data_gathering/get_report_data?session_id=#{id}", 'Authorization' => "Bearer #{token}") do |r|
        r.success do
          list = JSON(r.body).deep_symbolize_keys
        end
      end
    end

  end
end
