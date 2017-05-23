# frozen_string_literal: true

module SendGridActionMailerAdapter
  class ValidationError < StandardError; end

  class ApiError < StandardError
    attr_accessor :response

    def initialize(response)
      super("SendGrid API returns error, #{response.inspect}")
      @response = response
    end
  end
  class ApiClientError < ApiError; end
  class ApiUnexpectedError < ApiError; end
end
