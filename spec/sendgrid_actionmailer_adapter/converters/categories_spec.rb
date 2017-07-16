# frozen_string_literal: true

require 'spec_helper'
require 'mail'
require 'sendgrid-ruby'

RSpec.describe SendGridActionMailerAdapter::Converters::Categories do
  let(:converter) { SendGridActionMailerAdapter::Converters::Categories.new }
  let(:categories) { %w(aaa bbb ccc) }

  describe '#convert' do
    subject { converter.convert(mail) }

    let(:mail) { ::Mail.new }

    before do
      mail['categories'] = categories
    end

    it 'returns array of ::SendGrid::Category' do
      is_expected.to all(be_a(::SendGrid::Category))
      expect(subject.map(&:category)).to eq(categories)
    end

    context 'when categories is not specified' do
      let(:categories) { nil }

      it { is_expected.to be_nil }
    end
  end

  describe '#assign_attributes' do
    subject { converter.assign_attributes(sendgrid_mail, value) }

    let(:sendgrid_mail) { ::SendGrid::Mail.new }
    let(:value) { categories.map { |c| ::SendGrid::Category.new(name: c) } }

    it 'assigns categories to sendgrid_mail' do
      subject
      expect(sendgrid_mail.categories).to eq(categories)
    end
  end
end
