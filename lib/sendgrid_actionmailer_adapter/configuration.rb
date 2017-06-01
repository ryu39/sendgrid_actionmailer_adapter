# frozen_string_literal: true

module SendGridActionMailerAdapter
  class Configuration
    DEFAULT_RETRY_MAX_COUNT = 0
    DEFAULT_RETRY_WAIT_SECONDS = 1.0

    class << self
      attr_accessor :api_key, :host, :request_headers, :version, :retry_max_count,
                    :retry_wait_seconds, :return_response

      # Set your configuration with block.
      def configure
        yield(self)
      end

      # Returns configuration hash.
      #
      # @return [Hash]
      def settings
        @settings ||= {
          sendgrid: {
            api_key: api_key || '',
            host: host,
            request_headers: request_headers,
            version: version,
          },
          retry: {
            max_count: retry_max_count || DEFAULT_RETRY_MAX_COUNT,
            wait_seconds: retry_wait_seconds || DEFAULT_RETRY_WAIT_SECONDS,
          },
          return_response: return_response,
        }.freeze
      end

      # Reset settings for test.
      def reset!
        self.api_key = nil
        self.host = nil
        self.request_headers = nil
        self.version = nil
        self.retry_max_count = nil
        self.retry_wait_seconds = nil
        self.return_response = nil
        @settings = nil
      end
    end
  end
end
