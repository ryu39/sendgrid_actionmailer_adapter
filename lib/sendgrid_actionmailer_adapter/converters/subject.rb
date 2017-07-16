# frozen_string_literal: true

module SendGridActionMailerAdapter
  module Converters
    class Subject
      def convert(mail)
        mail.subject
      end

      def assign_attributes(sendgrid_mail, value)
        sendgrid_mail.subject = value
      end
    end
  end
end
