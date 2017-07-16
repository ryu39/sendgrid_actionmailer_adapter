# frozen_string_literal: true

require 'sendgrid-ruby'

module SendGridActionMailerAdapter
  module Converters
    class From
      def validate(mail)
        error_messages = []
        if mail.from_addrs.empty?
          error_messages << "'from' is required."
        end
        error_messages
      end

      def convert(mail)
        addr = mail[:from].addrs.first
        ::SendGrid::Email.new(email: addr.address, name: addr.display_name)
      end

      def assign_attributes(sendgrid_mail, value)
        sendgrid_mail.from = value
      end
    end
  end
end
