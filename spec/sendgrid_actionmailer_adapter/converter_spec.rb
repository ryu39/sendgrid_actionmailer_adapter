# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'base64'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converter do
  subject { SendGridActionMailerAdapter::Converter.to_sendgrid_mail(mail) }

  let(:mail) do
    Mail::Message.new.tap do |m|
      m.from = from
      m.to = to
      m.content_type = content_type
      m.subject = title
      m.body = body
    end
  end
  let(:from) { 'from@example.com' }
  let(:to) { %w[to_1@example.com to_2@example.com] }
  let(:title) { 'Title' }
  let(:content_type) { 'text/plain; charset=UTF-8' }
  let(:body) { 'Body' }

  describe 'validation' do
    it { expect { subject }.not_to raise_error }

    shared_examples_for 'validation error' do
      it 'raises SendGridActionMailerAdapter::ValidationError error' do
        expect { subject }.to raise_error(SendGridActionMailerAdapter::ValidationError)
      end
    end

    context 'when from is nil' do
      let(:from) { nil }

      it_behaves_like 'validation error'
    end

    context 'when from is empty' do
      let(:from) { '' }

      it_behaves_like 'validation error'
    end

    context 'when to is empty' do
      let(:to) { [] }

      it_behaves_like 'validation error'
    end

    context 'when subject is nil' do
      let(:title) { nil }

      it_behaves_like 'validation error'
    end

    context 'when subject is empty' do
      let(:title) { '' }

      it_behaves_like 'validation error'
    end
  end

  describe 'conversion' do
    it 'converts Mail::Message to SendGrid::Mail' do
      is_expected.to be_a(SendGrid::Mail)
    end

    it 'sets from address to SendGrid::Mail#from' do
      expect(subject.from['email']).to eq(from)
    end

    context 'when from contains display name' do
      let(:from) { "#{name} <#{addr}>" }
      let(:addr) { 'from@example.com' }
      let(:name) { 'From' }

      it 'sets from address and name to SendGrid::Mail#from' do
        expect(subject.from['email']).to eq(addr)
        expect(subject.from['name']).to eq(name)
      end
    end

    it 'sets subject to SendGrid::Mail#subject' do
      expect(subject.subject).to eq(title)
    end

    it 'sets mime_type and body to SendGrid::Mail#contents' do
      expect(subject.contents.first['type']).to eq(mail.mime_type)
      expect(subject.contents.first['value']).to eq(body)
    end

    it 'sets To addresses to personaliations separately' do
      expect(subject.personalizations.length).to eq(to.length)
      subject.personalizations.each.with_index do |p, i|
        expect(p['to'].first['email']).to eq(to[i])
      end
    end

    context 'when To addresses contain display names' do
      let(:to) { addrs.zip(names).map { |addr, name| "#{name} <#{addr}>" } }
      let(:addrs) { %w[to_1@example.com to_2@example.com] }
      let(:names) { %w[To1 To2] }

      it 'sets To addresses and names to personaliations separately' do
        subject.personalizations.each.with_index do |p, i|
          expect(p['to'].first['email']).to eq(addrs[i])
          expect(p['to'].first['name']).to eq(names[i])
        end
      end
    end

    context 'when mail contains cc addresses' do
      let(:cc) { %w[cc_1@example.com cc_2@example.com] }

      before do
        mail.cc = cc
      end

      it 'sets Cc addresses to all personalizations' do
        subject.personalizations.each do |p|
          expect(p['cc'].map { |addr| addr['email'] }).to eq(cc)
        end
      end

      context 'when cc addresses contains display names' do
        let(:cc) { addrs.zip(names).map { |addr, name| "#{name} <#{addr}>" } }
        let(:addrs) { %w[cc_1@example.com cc_2@example.com] }
        let(:names) { %w[Cc1 Cc2] }

        it 'sets Cc addresses and names to personaliations' do
          subject.personalizations.each do |p|
            expect(p['cc'].map { |addr| addr['email'] }).to eq(addrs)
            expect(p['cc'].map { |addr| addr['name'] }).to eq(names)
          end
        end
      end
    end

    context 'when mail contains bcc addresses' do
      let(:bcc) { %w[bcc_1@example.com bcc_2@example.com] }

      before do
        mail.bcc = bcc
      end

      it 'sets Bcc addresses to all personalizations' do
        subject.personalizations.each do |p|
          converted_bcc_addrs = p['bcc'].map { |addr| addr['email'] }
          expect(converted_bcc_addrs).to eq(bcc)
        end
      end

      context 'when bcc addresses contains display names' do
        let(:bcc) { addrs.zip(names).map { |addr, name| "#{name} <#{addr}>" } }
        let(:addrs) { %w[bcc_1@example.com bcc_2@example.com] }
        let(:names) { %w[Bcc1 Bcc2] }

        it 'sets Bcc addresses and names to personaliations' do
          subject.personalizations.each do |p|
            expect(p['bcc'].map { |addr| addr['email'] }).to eq(addrs)
            expect(p['bcc'].map { |addr| addr['name'] }).to eq(names)
          end
        end
      end
    end

    context 'when mail headers contain categories' do
      let(:categories) { %w[sales marketing] }

      before do
        mail['categories'] = categories
      end

      it 'sets categories to SendGrid::Mail#categories' do
        expect(subject.categories).to eq(categories)
      end
    end

    context 'when mail headers contain send_at' do
      let(:send_at) { 100 }

      before do
        mail['send_at'] = send_at
      end

      it 'sets send_at to SendGrid::Mail#send_at' do
        expect(subject.send_at).to eq(send_at)
      end
    end

    context 'when mail contains reply_to' do
      let(:reply_to) { 'reply_to@example.com' }

      before do
        mail.reply_to = reply_to
      end

      it 'sets reply_to to SendGrid::Mail#reply_to' do
        expect(subject.reply_to['email']).to eq(reply_to)
      end

      context 'when reply_to contains display_name' do
        let(:reply_to) { "#{name} <#{addr}>" }
        let(:addr) { 'reply_to@example.com' }
        let(:name) { 'ReplyTo' }

        it 'sets reply_to address and name to SendGrid::Mail#reply_to' do
          expect(subject.reply_to['email']).to eq(addr)
          expect(subject.reply_to['name']).to eq(name)
        end
      end
    end

    context 'when mail contains attachments' do
      let(:attachment_path) { './test_data/Lenna.jpg' }
      let(:attachment_filename) { File.basename(attachment_path) }
      let(:attachment_content) { IO.read(attachment_path) }

      before do
        mail.add_file(filename: attachment_filename, content: attachment_content)
      end

      it 'sets filename to SendGrid::Mail#attachments' do
        attachment = subject.attachments.first
        expect(attachment['filename']).to eq(attachment_filename)
      end

      it 'sets Base64 encoded content to SendGrid::Mail#attachments' do
        attachment = subject.attachments.first
        expect(attachment['content']).to eq(::Base64.strict_encode64(attachment_content))
      end
    end
  end
end
