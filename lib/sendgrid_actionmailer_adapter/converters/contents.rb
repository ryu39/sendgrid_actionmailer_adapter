# frozen_string_literal: true

require 'sendgrid-ruby'

module SendGridActionMailerAdapter
  module Converters
    class Contents
      def validate(_mail)
      end

      def convert(mail)
        unless mail.body.multipart?
          return ::SendGrid::Content.new(type: mail.mime_type, value: mail.body.to_s)
        end

        mail.body.parts.map do |part|
          ::SendGrid::Content.new(type: part.mime_type, value: part.body.to_s)
        end
      end

      def assign_attributes(sendgrid_mail, value)
        Array(value).each do |content|
          sendgrid_mail.add_content(content)
        end
      end
    end
  end
end
