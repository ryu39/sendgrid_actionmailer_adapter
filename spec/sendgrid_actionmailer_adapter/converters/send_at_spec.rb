# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converters::SendAt do
  let(:converter) { SendGridActionMailerAdapter::Converters::SendAt.new }
  let(:send_at) { Time.now.to_i }

  describe '#convert' do
    subject { converter.convert(mail) }

    before do
      mail['send_at'] = send_at
    end

    let(:mail) { ::Mail.new }

    it { is_expected.to eq(send_at) }

    context 'when send_at is not specified' do
      let(:send_at) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe '#assign_attributes' do
    subject { converter.assign_attributes(sendgrid_mail, value) }

    let(:sendgrid_mail) { ::SendGrid::Mail.new }
    let(:value) { send_at }

    it 'assigns send_at to sendgrid_mail' do
      subject
      expect(sendgrid_mail.send_at).to eq(send_at)
    end

    context 'when send_at is nil' do
      let(:value) { nil }

      it 'does not assigns send_at' do
        expect(sendgrid_mail.reply_to).to be_nil
      end
    end
  end
end
