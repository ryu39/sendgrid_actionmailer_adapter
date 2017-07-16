# frozen_string_literal: true

require 'sendgrid-ruby'

module SendGridActionMailerAdapter
  module Converters
    class Contents
      def convert(mail)
        ::SendGrid::Content.new(type: mail.mime_type, value: mail.body.to_s)
      end

      def assign_attributes(sendgrid_mail, value)
        Array(value).each do |content|
          sendgrid_mail.contents = content
        end
      end
    end
  end
end
