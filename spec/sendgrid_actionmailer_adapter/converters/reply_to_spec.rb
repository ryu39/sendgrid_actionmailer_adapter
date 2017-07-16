# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converters::ReplyTo do
  let(:converter) { SendGridActionMailerAdapter::Converters::ReplyTo.new }
  let(:addr) { 'reply-to@example.com' }
  let(:name) { 'ReplyTo' }

  describe '#convert' do
    subject { converter.convert(mail) }

    let(:mail) { ::Mail.new(reply_to: "#{name} <#{addr}>") }

    it { expect(subject.email).to eq(addr) }
    it { expect(subject.name).to eq(name) }

    context 'when reply_to is not specified' do
      let(:mail) { ::Mail.new }

      it { is_expected.to be_nil }
    end
  end

  describe '#assign_attributes' do
    subject { converter.assign_attributes(sendgrid_mail, value) }

    let(:sendgrid_mail) { ::SendGrid::Mail.new }
    let(:value) { ::SendGrid::Email.new(email: addr, name: name) }

    it 'assigns reply_to addr and name to sendgrid_mail' do
      subject
      expect(sendgrid_mail.reply_to['email']).to eq(addr)
      expect(sendgrid_mail.reply_to['name']).to eq(name)
    end

    context 'when reply_to is nil' do
      let(:value) { nil }

      it 'does not assigns reply_to' do
        expect(sendgrid_mail.reply_to).to be_nil
      end
    end
  end
end
