# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converters::Contents do
  let(:converter) { SendGridActionMailerAdapter::Converters::Contents.new }
  let(:type) { 'text/plain' }
  let(:body) { 'Body' }

  describe '#convert' do
    subject { converter.convert(mail) }

    let(:mail) { ::Mail.new(content_type: content_type, body: body) }
    let(:content_type) { "#{type}; charset=UTF-8" }

    it { expect(subject.type).to eq(type) }
    it { expect(subject.value).to eq(body) }
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
