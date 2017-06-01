# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SendGridActionMailerAdapter::Configuration do
  let(:api_key) { 'api_key' }
  let(:host) { 'host' }
  let(:request_headers) { { key: 'val' } }
  let(:version) { 'v3' }
  let(:retry_max_count) { 1 }
  let(:retry_wait_seconds) { 0.5 }
  let(:return_response) { true }

  before do
    SendGridActionMailerAdapter.configure do |config|
      config.api_key = api_key
      config.host = host
      config.request_headers = request_headers
      config.version = version
      config.retry_max_count = retry_max_count
      config.retry_wait_seconds = retry_wait_seconds
      config.return_response = return_response
    end
  end

  after do
    SendGridActionMailerAdapter::Configuration.reset!
  end

  describe '.settings' do
    subject { SendGridActionMailerAdapter::Configuration.settings }

    let(:expected) do
      {
        sendgrid: {
          api_key: api_key,
          host: host,
          request_headers: request_headers,
          version: version,
        },
        retry: {
          max_count: retry_max_count,
          wait_seconds: retry_wait_seconds,
        },
        return_response: return_response,
      }
    end

    it { is_expected.to eq(expected) }
  end
end
