# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sendgrid_actionmailer_adapter'

require 'action_mailer'

# rubocop:disable Metrics/BlockLength
RSpec.describe 'Integration test, send mails using ActionMailer' do
  subject { mail.deliver_now! }

  let(:mail) { mailer_class.send_test_mail(base_params.merge(params)) }
  let(:mailer_class) do
    Class.new(ActionMailer::Base) do
      self.delivery_method = SendGridActionMailerAdapter::DeliveryMethod

      default from: 'from@example.com', reply_to: 'reply_to@example.com'

      def send_test_mail(params)
        mail(params)
      end
    end
  end
  let(:base_params) do
    {
      to: ENV['TEST_MAIL_ADDRESS_TO'],
      subject: 'test mail',
      body: 'This is a test mail',
    }
  end
  let(:params) { {} }

  before do
    SendGridActionMailerAdapter.configure do |config|
      config.api_key = ENV['SENDGRID_API_KEY']
      config.return_response = true
    end
  end

  after do
    SendGridActionMailerAdapter::Configuration.reset!
  end

  shared_examples_for 'success mail API request' do
    it 'returns success response' do
      expect { subject }.not_to raise_error
      expect(subject.status_code.to_i).to(satisfy { |code| (200..299).cover?(code) })
    end
  end

  it_behaves_like 'success mail API request'

  context 'with cc' do
    let(:params) do
      {
        subject: 'test mail with cc',
        cc: ENV['TEST_MAIL_ADDRESS_CC'],
      }
    end

    it_behaves_like 'success mail API request'
  end

  context 'with bcc' do
    let(:params) do
      {
        subject: 'test mail with bcc',
        bcc: ENV['TEST_MAIL_ADDRESS_BCC'],
      }
    end

    it_behaves_like 'success mail API request'
  end

  context 'with attachments' do
    let(:params) do
      { subject: 'test mail with attachments' }
    end
    let(:test_file_path) { File.expand_path('../../test_data/Lenna.jpg', __FILE__) }

    before do
      mail.add_file(test_file_path)
    end

    it_behaves_like 'success mail API request'
  end

  context 'with html mail' do
    let(:params) do
      { subject: 'test mail with text and html' }
    end
    let(:html_mail_body) do
      <<~HTML_MAIL
        <html>
          <head>
            <title>title</title>
          </head>
          <body>
            <h1>Test</h1>
            <p>This is a test mail.</p>
          </body>
        </html>
      HTML_MAIL
    end

    before do
      mail.html_part = html_mail_body
    end

    it_behaves_like 'success mail API request'
  end

  context 'with categories' do
    let(:params) do
      {
        subject: 'test mail with categories',
        categories: %w(Test1 Test2),
      }
    end

    it_behaves_like 'success mail API request'
  end

  context 'with send_at' do
    let(:params) do
      {
        subject: 'test mail with send_at',
        send_at: Time.now.to_i,
      }
    end

    it_behaves_like 'success mail API request'
  end

  context 'with remove_from_bounces' do
    let(:params) do
      {
        subject: 'test mail with remove_from_bounces',
        remove_from_bounces: true,
      }
    end

    it_behaves_like 'success mail API request'
  end
end
