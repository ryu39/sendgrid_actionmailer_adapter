# frozen_string_literal: true

require 'mail'
require 'base64'
require 'sendgrid-ruby'

module SendGridActionMailerAdapter
  module Converters
    class Attachments
      def validate(_mail)
      end

      def convert(mail)
        mail.attachments.map do |attachment|
          ::SendGrid::Attachment.new.tap do |sendgrid_attachment|
            sendgrid_attachment.type = attachment.mime_type
            sendgrid_attachment.content = ::Base64.strict_encode64(attachment.body.raw_source)
            sendgrid_attachment.filename = ::Mail::Encodings.decode_encode(
              attachment.content_type_parameters['filename'], :decode
            )
            sendgrid_attachment.content_id = attachment.cid
          end
        end
      end

      def assign_attributes(sendgrid_mail, value)
        Array(value).each do |attachment|
          sendgrid_mail.add_attachment(attachment)
        end
      end
    end
  end
end
