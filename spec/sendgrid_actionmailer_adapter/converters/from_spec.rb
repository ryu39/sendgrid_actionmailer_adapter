# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converters::From do
  let(:converter) { SendGridActionMailerAdapter::Converters::From.new }
  let(:addr) { 'from@example.com' }
  let(:name) { 'From' }

  describe '#validate' do
    subject { converter.validate(mail) }

    let(:mail) { ::Mail.new(from: addr) }

    it { is_expected.to be_empty }

    context 'when from is nil' do
      let(:addr) { nil }

      it { is_expected.not_to be_empty }
    end
  end

  describe '#convert' do
    subject { converter.convert(mail) }

    let(:mail) { ::Mail.new(from: "#{name} <#{addr}>") }

    it { expect(subject.email).to eq(addr) }
    it { expect(subject.name).to eq(name) }
  end

  describe '#assign_attributes' do
    subject { converter.assign_attributes(sendgrid_mail, value) }

    let(:sendgrid_mail) { ::SendGrid::Mail.new }
    let(:value) { ::SendGrid::Email.new(email: addr, name: name) }

    it 'assigns from addr and name to sendgrid_mail' do
      subject
      expect(sendgrid_mail.from['email']).to eq(addr)
      expect(sendgrid_mail.from['name']).to eq(name)
    end
  end
end
