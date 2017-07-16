# frozen_string_literal: true

require 'sendgrid-ruby'

module SendGridActionMailerAdapter
  module Converters
    class Categories
      def validate(_mail)
      end

      def convert(mail)
        categories_str = mail['categories']&.value
        return if categories_str.nil? || categories_str.empty?
        categories_str.split(', ').map { |c| ::SendGrid::Category.new(name: c) }
      end

      def assign_attributes(sendgrid_mail, value)
        Array(value).each do |category|
          sendgrid_mail.categories = category
        end
      end
    end
  end
end
