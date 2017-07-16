# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'base64'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converter do
  subject { SendGridActionMailerAdapter::Converter.to_sendgrid_mail(mail) }

  let(:mail) do
    mail = Mail::Message.new.tap do |m|
      m.from = from
      m.to = to
      m.cc = cc
      m.bcc = bcc
      m.reply_to = reply_to
      m.content_type = content_type
      m.subject = title
      m.body = body
    end
    mail.add_file(filename: attachment_filename, content: attachment_content)
    mail['categories'] = categories
    mail['send_at'] = send_at
    mail
  end
  let(:from) { 'from@example.com' }
  let(:to) { ['to_1@example.com', 'to_2@example.com'] }
  let(:cc) { ['cc_1@example.com', 'cc_2@example.com'] }
  let(:bcc) { ['bcc_1@example.com', 'bcc_2@example.com'] }
  let(:reply_to) { 'reply_to@example.com' }
  let(:title) { 'Title' }
  let(:content_type) { 'text/plain; charset=UTF-8' }
  let(:body) { 'Body' }
  let(:attachment_filename) { File.basename(attachment_path) }
  let(:attachment_path) { './test_data/Lenna.jpg' }
  let(:attachment_content) { IO.read(attachment_path) }
  let(:categories) { %w(aaa bbb ccc) }
  let(:send_at) { Time.now.to_i }

  describe 'validation' do
    let(:from) { nil }

    it 'raises SendGridActionMailerAdapter::ValidationError error' do
      expect { subject }.to raise_error(SendGridActionMailerAdapter::ValidationError)
    end
  end

  describe 'conversion' do
    it 'converts Mail::Message to SendGrid::Mail' do
      is_expected.to be_a(SendGrid::Mail)
    end

    it 'sets from to SendGrid::Mail' do
      expect(subject.from['email']).to eq(from)
    end

    it 'sets to to SendGrid::Mail' do
      to.each.with_index do |to_addr, i|
        expect(subject.personalizations.dig(i, 'to', 0, 'email')).to eq(to_addr)
      end
    end

    it 'sets cc to SendGrid::Mail' do
      expected = cc.map { |cc_addr| { 'email' => cc_addr } }
      subject.personalizations.each do |p|
        expect(p['cc']).to eq(expected)
      end
    end

    it 'sets bcc to SendGrid::Mail' do
      expected = bcc.map { |bcc_addr| { 'email' => bcc_addr } }
      subject.personalizations.each do |p|
        expect(p['bcc']).to eq(expected)
      end
    end

    it 'sets reply_to to SendGrid::Mail' do
      expect(subject.reply_to['email']).to eq(reply_to)
    end

    it 'sets attachments to SendGrid::Mail' do
      attachment = subject.attachments.first
      expect(attachment['type']).to eq('image/jpeg')
      expect(attachment['content']).to eq(::Base64.strict_encode64(attachment_content))
      expect(attachment['filename']).to eq(attachment_filename)
      expect(attachment['content_id']).not_to be_nil
    end

    it 'sets categories to SendGrid::Mail' do
      expect(subject.categories).to eq(categories)
    end

    it 'sets send_at to SendGrid::Mail' do
      expect(subject.send_at).to eq(send_at)
    end
  end
end
