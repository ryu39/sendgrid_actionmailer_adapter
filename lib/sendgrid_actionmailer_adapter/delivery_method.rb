# frozen_string_literal: true

require 'logger'
require 'sendgrid/client'
require_relative 'configuration'
require_relative 'converter'
require_relative 'errors'

module SendGridActionMailerAdapter
  class DeliveryMethod
    attr_reader :settings

    # Initialize this instance.
    #
    # This method is expected to be called from Mail::Message class.
    #
    # @params [Hash] settings settings parameters which you want to override.
    # @options settings [String] :api_key Your SendGrid Web API key.
    # @options settings [String] :host Base host FQDN of API endpoint.
    # @options settings [Hash] :request_headers Request headers which you want to override.
    # @options settings [String] :version API version string, eg: 'v3'.
    # @options settings [Integer] :retry_max_count Count for retry, Default is 0(Do not retry).
    # @options settings [Integer, Float] :retry_wait_sec Wait seconds for next retry, Default is 1.
    def initialize(settings)
      @settings = ::SendGridActionMailerAdapter::Configuration.settings.merge(settings)
      @logger = @settings[:logger] || ::Logger.new(nil)
    end

    # Deliver a mail via SendGrid Web API.
    #
    # This method is called from Mail::Message#deliver!.
    #
    # @param [Mail::Message] mail Mail::Message object which you want to send.
    # @raise [SendGridActionMailerAdapter::ValidationError] when validation error occurred.
    # @raise [SendGridActionMailerAdapter::ApiError] when SendGrid Web API returns error response.
    def deliver!(mail)
      sendgrid_mail = ::SendGridActionMailerAdapter::Converter.to_sendgrid_mail(mail)

      if mail[:remove_from_bounces]
        remove_to_addrs_from_bounces(sendgrid_mail)
      end

      with_retry(@settings[:retry]) do
        @logger.info("Calling sendMail API, #{extract_log_info(sendgrid_mail)}")
        response = sendgrid_client.mail._('send').post(request_body: sendgrid_mail.to_json)
        @logger.info("End calling sendMail API, status_code: #{response.status_code}")
        handle_response!(response)
      end
    end

    private

    def sendgrid_client
      @sendgrid_client ||= ::SendGrid::API.new(@settings[:sendgrid]).client
    end

    # @param [::SendGrid::Mail]
    def remove_to_addrs_from_bounces(sendgrid_mail)
      sendgrid_mail.personalizations.each do |personalization|
        personalization['to'].each do |to|
          @logger.info("Calling deleteBounce API, #{to}")
          # success => 204, not_found => 404
          sendgrid_client.suppression.bounces._(to['email']).delete
          @logger.info('End calling deleteBounce API')
        end
      end
    end

    def with_retry(max_count:, wait_seconds:)
      tryable_count = max_count + 1
      begin
        tryable_count -= 1
        yield
      rescue ::SendGridActionMailerAdapter::ApiClientError => e
        @logger.error(e)
        raise
      rescue StandardError => e
        if tryable_count > 0
          @logger.warn("Retry mail sending, tryable_count: #{tryable_count}")
          @logger.warn(e)
          sleep(wait_seconds)
          retry
        end
        @logger.error('Give up retrying')
        @logger.error(e)
        raise
      end
    end

    def extract_log_info(sendgrid_mail)
      {
        subject: sendgrid_mail.subject,
        personalizations: sendgrid_mail.personalizations,
      }
    end

    # @see https://sendgrid.com/docs/API_Reference/Web_API_v3/Mail/errors.html
    def handle_response!(response)
      case response.status_code.to_i
      when (200..299)
        response
      when (400..499)
        raise ::SendGridActionMailerAdapter::ApiClientError, response
      else
        raise ::SendGridActionMailerAdapter::ApiUnexpectedError, response
      end
    end
  end
end
