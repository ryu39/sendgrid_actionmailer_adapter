# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converters::Personalizations do
  let(:converter) { SendGridActionMailerAdapter::Converters::Personalizations.new }
  let(:to_addrs) { [to_1, to_2] }
  let(:cc_addrs) { [cc_1, cc_2] }
  let(:bcc_addrs) { [bcc_1, bcc_2] }
  let(:to_1) { 'to_1@example.com' }
  let(:to_2) { "#{to_2_name} <#{to_2_email}>" }
  let(:to_2_name) { 'to_2' }
  let(:to_2_email) { 'to_2@example.com' }
  let(:cc_1) { 'cc_1@example.com' }
  let(:cc_2) { "#{cc_2_name} <#{cc_2_email}>" }
  let(:cc_2_name) { 'cc_2' }
  let(:cc_2_email) { 'cc_2@example.com' }
  let(:bcc_1) { 'bcc_1@example.com' }
  let(:bcc_2) { "#{bcc_2_name} <#{bcc_2_email}>" }
  let(:bcc_2_name) { 'bcc_2' }
  let(:bcc_2_email) { 'bcc_2@example.com' }

  describe '#convert' do
    subject { converter.convert(mail) }

    let(:mail) { ::Mail.new(to: to_addrs, cc: cc_addrs, bcc: bcc_addrs) }

    it 'returns array of ::SendGrid::Personalization' do
      is_expected.to all(be_a(::SendGrid::Personalization))
    end

    it 'converts each to_addrs to ::SendGrid::Personalization' do
      expect(subject.length).to eq(to_addrs.length)
      expect(subject[0].tos[0]['email']).to eq(to_1)
      expect(subject[0].tos[0]['name']).to be_nil
      expect(subject[1].tos[0]['email']).to eq(to_2_email)
      expect(subject[1].tos[0]['name']).to eq(to_2_name)
    end

    it 'sets all cc_addrs to all personalizations' do
      expected = [
        { 'email' => cc_1 },
        { 'email' => cc_2_email, 'name' => cc_2_name },
      ]
      subject.each do |personalization|
        expect(personalization.ccs).to eq(expected)
      end
    end

    it 'sets all bcc_addrs to all personalizations' do
      expected = [
        { 'email' => bcc_1 },
        { 'email' => bcc_2_email, 'name' => bcc_2_name },
      ]
      subject.each do |personalization|
        expect(personalization.bccs).to eq(expected)
      end
    end
  end

  describe '#assign_attributes' do
    subject { converter.assign_attributes(sendgrid_mail, value) }

    let(:sendgrid_mail) { ::SendGrid::Mail.new }
    let(:value) { [personalization_1, personalization_2] }
    let(:personalization_1) {
      ::SendGrid::Personalization.new.tap do |p|
        p.to = ::SendGrid::Email.new(email: to_1)
        p.cc = ::SendGrid::Email.new(email: cc_1)
        p.cc = ::SendGrid::Email.new(email: cc_2_email, name: cc_2_name)
        p.bcc = ::SendGrid::Email.new(email: bcc_1)
        p.bcc = ::SendGrid::Email.new(email: bcc_2_email, name: bcc_2_name)
      end
    }
    let(:personalization_2) {
      ::SendGrid::Personalization.new.tap do |p|
        p.to = ::SendGrid::Email.new(email: to_2_email, name: to_2_name)
        p.cc = ::SendGrid::Email.new(email: cc_1)
        p.cc = ::SendGrid::Email.new(email: cc_2_email, name: cc_2_name)
        p.bcc = ::SendGrid::Email.new(email: bcc_1)
        p.bcc = ::SendGrid::Email.new(email: bcc_2_email, name: bcc_2_name)
      end
    }

    it 'adds each personalization to sendgrid_mail' do
      subject
      expect(sendgrid_mail.personalizations.length).to eq(2)
      expect(sendgrid_mail.personalizations[0]).to eq(personalization_1.to_json)
      expect(sendgrid_mail.personalizations[1]).to eq(personalization_2.to_json)
    end
  end
end
