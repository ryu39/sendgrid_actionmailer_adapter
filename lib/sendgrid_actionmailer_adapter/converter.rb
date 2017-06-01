# frozen_string_literal: true

require 'base64'
require 'mail'
require 'sendgrid-ruby'
require_relative 'errors'

module SendGridActionMailerAdapter
  class Converter
    VALIDATORS = [
      ->(mail) { "'from' is required." if mail.from_addrs.empty? },
      ->(mail) { "'to_addrs' must not be empty." if mail.to_addrs.empty? },
      ->(mail) { "'subject' is required." if mail.subject.nil? || mail.subject.empty? },
    ].freeze

    CONVERTERS = {
      from: ->(mail) {
        addr = mail[:from].addrs.first
        ::SendGrid::Email.new(email: addr.address, name: addr.display_name)
      },
      subject: ->(mail) { mail.subject },
      personalizations: ->(mail) {
        # Separate emails per each To address.
        # Cc and Bcc addresses are shared with each emails.
        mail[:to].addrs.map do |to_addr|
          ::SendGrid::Personalization.new.tap do |p|
            p.to = ::SendGrid::Email.new(email: to_addr.address, name: to_addr.display_name)
            Array(mail[:cc]&.addrs).each do |addr|
              p.cc = ::SendGrid::Email.new(email: addr.address, name: addr.display_name)
            end
            Array(mail[:bcc]&.addrs).each do |addr|
              p.bcc = ::SendGrid::Email.new(email: addr.address, name: addr.display_name)
            end
          end
        end
      },
      contents: ->(mail) {
        ::SendGrid::Content.new(type: mail.mime_type, value: mail.body.to_s)
      },
      attachments: ->(mail) {
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
      },
      categories: ->(mail) {
        return nil if mail['categories'].nil?
        # FIXME: Separator ', ' is dependant on Mail::UnstructuredField implementation,
        # this may occur unexpected behaviour on 'mail' gem update.
        mail['categories'].value.split(', ').map { |c| ::SendGrid::Category.new(name: c) }
      },
      send_at: ->(mail) { mail['send_at'].value.to_i if mail['send_at'] },
      reply_to: ->(mail) {
        addr = mail[:reply_to]&.addrs&.first
        ::SendGrid::Email.new(email: addr.address, name: addr.display_name) if addr
      },
    }.freeze

    class << self
      # Convert Mail::Message to SendGrid::Mail.
      #
      # @param [Message::Mail] mail
      # @return [SendGrid::Mail]
      # @raise [SendGridActionMailerAdapter::ValidationError]
      def to_sendgrid_mail(mail)
        validate!(mail)
        convert(mail)
      end

      private

      def validate!(mail)
        error_messages = VALIDATORS.map { |validator| validator.call(mail) }.compact
        unless error_messages.empty?
          raise SendGridActionMailerAdapter::ValidationError, "Validation error, #{error_messages}"
        end
      end

      def convert(mail)
        sendgrid_mail = ::SendGrid::Mail.new
        CONVERTERS.each do |attr_name, converter|
          Array(converter.call(mail)).each do |attr_val|
            sendgrid_mail.send("#{attr_name}=", attr_val)
          end
        end
        sendgrid_mail
      end
    end
  end
end
