# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converters::Contents do
  let(:converter) { SendGridActionMailerAdapter::Converters::Contents.new }
  let(:attachment_file_path) { File.expand_path('../../../../test_data/Lenna.jpg', __FILE__) }

  describe '#convert' do
    subject { converter.convert(mail) }

    let(:mail) { ::Mail.new(content_type: 'text/plain; charset=UTF-8', body: 'Body') }

    it 'returns arrays which contains text/plain mail body' do
      expect(subject.first.type).to eq('text/plain')
      expect(subject.first.value).to eq('Body')
    end

    context 'when mail is multipart(text/plain and text/html)' do
      before do
        mail.html_part = '<html></html>'
      end

      it 'returns array which contains text/plain and text/html content' do
        expect(subject.length).to eq(2)

        expect(subject.first.type).to eq('text/plain')
        expect(subject.first.value).to eq('Body')

        expect(subject.last.type).to eq('text/html')
        expect(subject.last.value).to eq('<html></html>')
      end
    end

    context 'when mail is multipart(not text file)' do
      before do
        mail.add_file(attachment_file_path)
      end

      it 'returns array which contains only text content' do
        expect(subject.length).to eq(1)
        expect(subject.first.type).to eq('text/plain')
        expect(subject.first.value).to eq('Body')
      end
    end
  end

  describe '#assign_attributes' do
    subject { converter.assign_attributes(sendgrid_mail, value) }

    let(:sendgrid_mail) { ::SendGrid::Mail.new }
    let(:value) { [::SendGrid::Content.new(type: 'text/plain', value: 'Body')] }

    it 'assigns contents to sendgrid_mail' do
      subject
      expect(sendgrid_mail.contents.length).to eq(1)
      content = sendgrid_mail.contents.first
      expect(content['type']).to eq('text/plain')
      expect(content['value']).to eq('Body')
    end
  end
end
