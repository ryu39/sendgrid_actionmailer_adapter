# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converters::Contents do
  let(:converter) { SendGridActionMailerAdapter::Converters::Contents.new }
  let(:type) { 'text/plain' }
  let(:body) { 'Body' }
  let(:attachment_file_path) { File.expand_path('../../../../test_data/Lenna.jpg', __FILE__) }

  describe '#convert' do
    subject { converter.convert(mail) }

    let(:mail) { ::Mail.new(content_type: content_type, body: body) }
    let(:content_type) { "#{type}; charset=UTF-8" }

    it { expect(subject.type).to eq(type) }
    it { expect(subject.value).to eq(body) }

    context 'when mail is multipart' do
      before do
        mail.add_file(attachment_file_path)
      end

      it 'returns content which of content type is text' do
        expect(subject.type).to eq(type)
        expect(subject.value).to eq(body)
      end
    end
  end

  describe '#assign_attributes' do
    subject { converter.assign_attributes(sendgrid_mail, value) }

    let(:sendgrid_mail) { ::SendGrid::Mail.new }
    let(:value) { ::SendGrid::Content.new(type: type, value: body) }

    it 'assigns contents to sendgrid_mail' do
      subject
      expect(sendgrid_mail.contents.length).to eq(1)
      content = sendgrid_mail.contents.first
      expect(content['type']).to eq(type)
      expect(content['value']).to eq(body)
    end
  end
end
