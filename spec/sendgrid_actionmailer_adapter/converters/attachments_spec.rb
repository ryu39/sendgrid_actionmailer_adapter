# frozen_string_literal: true

require 'base64'
require 'spec_helper'
require 'mail'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converters::Attachments do
  let(:converter) { SendGridActionMailerAdapter::Converters::Attachments.new }
  let(:attachment_filename) { File.basename(attachment_path) }
  let(:attachment_path) { './test_data/Lenna.jpg' }
  let(:attachment_content) { IO.read(attachment_path) }

  describe '#convert' do
    subject { converter.convert(mail) }

    let(:mail) { ::Mail.new }

    before do
      mail.add_file(filename: attachment_filename, content: attachment_content)
    end

    it 'returns array of ::SendGrid::Attachment' do
      expect(subject).to all(be_a(::SendGrid::Attachment))
      attachment = subject.first
      expect(attachment.type).to eq('image/jpeg')
      expect(attachment.content_id).to eq(mail.attachments.first.cid)
    end

    it 'sets content encoded by Base64' do
      attachment = subject.first
      expect(attachment.content).to eq(::Base64.strict_encode64(attachment_content))
    end

    it 'sets filename' do
      attachment = subject.first
      expect(attachment.filename).to eq(attachment_filename)
    end
  end

  describe '#assign_attributes' do
    subject { converter.assign_attributes(sendgrid_mail, value) }

    let(:sendgrid_mail) { ::SendGrid::Mail.new }
    let(:value) {
      ::SendGrid::Attachment.new.tap do |sendgrid_attachment|
        sendgrid_attachment.type = mime_type
        sendgrid_attachment.content = ::Base64.strict_encode64(attachment_content)
        sendgrid_attachment.filename = attachment_filename
        sendgrid_attachment.content_id = content_id
      end
    }
    let(:mime_type) { 'image/jpeg' }
    let(:content_id) { Time.now.to_i }

    it 'assigns attachment to sendgrid_mail' do
      subject
      expect(sendgrid_mail.attachments.length).to eq(1)
      attachment = sendgrid_mail.attachments.first
      expect(attachment['type']).to eq(mime_type)
      expect(attachment['content']).to eq(::Base64.strict_encode64(attachment_content))
      expect(attachment['filename']).to eq(attachment_filename)
      expect(attachment['content_id']).to eq(content_id)
    end
  end
end
