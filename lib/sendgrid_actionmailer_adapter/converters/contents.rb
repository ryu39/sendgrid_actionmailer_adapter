# frozen_string_literal: true

require 'sendgrid-ruby'

module SendGridActionMailerAdapter
  module Converters
    class Contents
      def validate(_mail)
      end

      def convert(mail)
        contents = mail.body.multipart? ? mail.body.parts.select(&:text?) : [mail]
        contents.map { |c| ::SendGrid::Content.new(type: c.mime_type, value: c.body.to_s) }
      end

      def assign_attributes(sendgrid_mail, value)
        Array(value).each do |content|
          sendgrid_mail.add_content(content)
        end
      end
    end
  end
end
