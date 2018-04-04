# frozen_string_literal: true

require 'sendgrid-ruby'

module SendGridActionMailerAdapter
  module Converters
    class Contents
      def validate(_mail)
      end

      def convert(mail)
        main_part = mail.body.parts.detect(&:text?) || mail
        ::SendGrid::Content.new(type: main_part.mime_type, value: main_part.body.to_s)
      end

      def assign_attributes(sendgrid_mail, value)
        Array(value).each do |content|
          sendgrid_mail.add_content(content)
        end
      end
    end
  end
end
