# frozen_string_literal: true

require 'sendgrid-ruby'

module SendGridActionMailerAdapter
  module Converters
    class SendAt
      def validate(_mail)
      end

      def convert(mail)
        send_at_str = mail['send_at']&.value
        return if send_at_str.nil? || send_at_str.empty?
        send_at_str.to_i
      end

      def assign_attributes(sendgrid_mail, value)
        sendgrid_mail.send_at = value
      end
    end
  end
end
