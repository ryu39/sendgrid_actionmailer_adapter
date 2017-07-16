# frozen_string_literal: true

module SendGridActionMailerAdapter
  module Converters
    class Subject
      def validate(mail)
        error_messages = []
        if mail.subject.nil? || mail.subject.empty?
          error_messages << "'subject' is required."
        end
        error_messages
      end

      def convert(mail)
        mail.subject
      end

      def assign_attributes(sendgrid_mail, value)
        sendgrid_mail.subject = value
      end
    end
  end
end
