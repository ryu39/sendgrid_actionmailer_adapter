# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converters::Subject do
  let(:converter) { SendGridActionMailerAdapter::Converters::Subject.new }
  let(:title) { 'title' }

  describe '#validate' do
    subject { converter.validate(mail) }

    let(:mail) { ::Mail.new(subject: title) }

    it { is_expected.to be_empty }

    context 'when subject is nil' do
      let(:title) { nil }

      it { is_expected.not_to be_empty }
    end

    context 'when subject is empty string' do
      let(:title) { '' }

      it { is_expected.not_to be_empty }
    end
  end

  describe '#convert' do
    subject { converter.convert(mail) }

    let(:mail) { ::Mail.new(subject: title) }

    it { is_expected.to eq(title) }
  end

  describe '#assign_attributes' do
    subject { converter.assign_attributes(sendgrid_mail, value) }

    let(:sendgrid_mail) { ::SendGrid::Mail.new }
    let(:value) { title }

    it 'assigns subject to sendgrid_mail' do
      subject
      expect(sendgrid_mail.subject).to eq(title)
    end
  end
end
