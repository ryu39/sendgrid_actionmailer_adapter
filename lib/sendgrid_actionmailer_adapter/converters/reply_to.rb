# frozen_string_literal: true

require 'sendgrid-ruby'

module SendGridActionMailerAdapter
  module Converters
    class ReplyTo
      def convert(mail)
        addr = mail[:reply_to]&.addrs&.first
        return if addr.nil?
        ::SendGrid::Email.new(email: addr.address, name: addr.display_name)
      end

      def assign_attributes(sendgrid_mail, value)
        sendgrid_mail.reply_to = value
      end
    end
  end
end
