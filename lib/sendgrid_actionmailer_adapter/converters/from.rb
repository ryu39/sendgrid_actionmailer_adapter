# frozen_string_literal: true

require 'sendgrid-ruby'

module SendGridActionMailerAdapter
  module Converters
    class From
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
