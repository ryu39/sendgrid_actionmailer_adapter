# frozen_string_literal: true

require 'sendgrid-ruby'

module SendGridActionMailerAdapter
  module Converters
    class Personalizations
      def validate(mail)
        error_messages = []
        if mail.to_addrs.empty?
          error_messages << "'to_addrs' must not be empty."
        end
        error_messages
      end

      def convert(mail)
        # Separate emails per each To address.
        # Cc and Bcc addresses are shared with each emails.
        cc_addrs = mail[:cc]&.addrs
        bcc_addrs = mail[:bcc]&.addrs
        mail[:to].addrs.map do |to_addr|
          to_personalization(to_addr, cc_addrs, bcc_addrs)
        end
      end

      def assign_attributes(sendgrid_mail, value)
        Array(value).each do |personalization|
          sendgrid_mail.personalizations = personalization
        end
      end

      private

      def to_personalization(to_addr, cc_addrs, bcc_addrs)
        ::SendGrid::Personalization.new.tap do |p|
          p.to = ::SendGrid::Email.new(email: to_addr.address, name: to_addr.display_name)
          Array(cc_addrs).each do |addr|
            p.cc = ::SendGrid::Email.new(email: addr.address, name: addr.display_name)
          end
          Array(bcc_addrs).each do |addr|
            p.bcc = ::SendGrid::Email.new(email: addr.address, name: addr.display_name)
          end
        end
      end
    end
  end
end
