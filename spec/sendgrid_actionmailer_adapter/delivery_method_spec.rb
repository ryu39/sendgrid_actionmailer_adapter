# frozen_string_literal: true

require 'spec_helper'
require 'mail'

RSpec.describe SendGridActionMailerAdapter::DeliveryMethod do
  let(:deliverer) { SendGridActionMailerAdapter::DeliveryMethod.new(settings) }
  let(:settings) { {} }

  before do
    stub_request(:any, 'https://api.sendgrid.com')
  end

  describe '#deliver!' do
    subject { deliverer.deliver!(mail) }

    let(:mail) do
      Mail::Message.new.tap do |m|
        m.from = from
        m.to = to_addrs
        m.cc = cc_addrs
        m.bcc = bcc_addrs
        m.content_type = content_type
        m.subject = title
        m.body = body
      end
    end
    let(:from) { 'from@example.com' }
    let(:to_addrs) { %w[to_1@example.com to_2@example.com] }
    let(:cc_addrs) { %w[cc_1@example.com cc_2@example.com] }
    let(:bcc_addrs) { %w[bcc_1@example.com bcc_2@example.com] }
    let(:title) { 'Title' }
    let(:content_type) { 'text/plain; charset=UTF-8' }
    let(:body) { 'Body' }
    let(:request_body) do
      ::SendGridActionMailerAdapter::Converter.to_sendgrid_mail(mail).to_json
    end

    it 'posts JSON request to SendGrid Web API endpoint' do
      stub = stub_request(:post, 'https://api.sendgrid.com/v3/mail/send').with(body: request_body)
      expect { subject }.not_to raise_error
      expect(stub).to have_been_requested
    end

    shared_examples_for 'retryable' do
      let(:settings) do
        {
          retry: { max_count: 1, wait_seconds: 0 }
        }
      end

      it 'recalls SendGrid Web API' do
        stub = stub_request(:post, 'https://api.sendgrid.com/v3/mail/send').to_return(status: 500)
        expect { subject }.to raise_error(::SendGridActionMailerAdapter::ApiUnexpectedError)
        expect(stub).to have_been_requested.twice
      end
    end

    context 'with invalid mail' do
      let(:from) { nil }

      it 'raises ValidationError' do
        expect { subject }.to raise_error(::SendGridActionMailerAdapter::ValidationError)
      end
    end

    context 'when SendGrid Web API returns 400 error' do
      before do
        stub_request(:post, 'https://api.sendgrid.com/v3/mail/send').to_return(status: 400)
      end

      it 'raises ApiClientError' do
        expect { subject }.to raise_error(::SendGridActionMailerAdapter::ApiClientError)
      end
    end

    context 'when SendGrid Web API returns 500 error' do
      before do
        stub_request(:post, 'https://api.sendgrid.com/v3/mail/send').to_return(status: 500)
      end

      it 'raises ApiUnexpectedError' do
        expect { subject }.to raise_error(::SendGridActionMailerAdapter::ApiUnexpectedError)
      end

      it_behaves_like 'retryable'
    end

    context 'when SendGrid Web API raises error' do
      let(:error) { StandardError.new('test') }

      before do
        stub_request(:post, 'https://api.sendgrid.com/v3/mail/send').and_raise(error)
      end

      it 'raises error occurred in SendGrid::API' do
        expect { subject }.to raise_error(error)
      end

      it_behaves_like 'retryable'
    end
  end
end
