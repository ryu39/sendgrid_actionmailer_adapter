# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converters::Subject do
  let(:converter) { SendGridActionMailerAdapter::Converters::Subject.new }
  let(:title) { 'title' }

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
