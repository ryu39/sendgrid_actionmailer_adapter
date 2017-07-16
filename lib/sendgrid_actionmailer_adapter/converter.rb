# frozen_string_literal: true

require 'sendgrid-ruby'
require_relative 'errors'
require_relative 'converters/subject'
require_relative 'converters/from'
require_relative 'converters/personalizations'
require_relative 'converters/attachments'
require_relative 'converters/contents'
require_relative 'converters/categories'
require_relative 'converters/send_at'
require_relative 'converters/reply_to'

module SendGridActionMailerAdapter
  class Converter
    CONVERTERS = [
      ::SendGridActionMailerAdapter::Converters::From.new,
      ::SendGridActionMailerAdapter::Converters::Subject.new,
      ::SendGridActionMailerAdapter::Converters::Personalizations.new,
      ::SendGridActionMailerAdapter::Converters::Attachments.new,
      ::SendGridActionMailerAdapter::Converters::Contents.new,
      ::SendGridActionMailerAdapter::Converters::Categories.new,
      ::SendGridActionMailerAdapter::Converters::SendAt.new,
      ::SendGridActionMailerAdapter::Converters::ReplyTo.new,
    ].freeze

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
        error_messages = CONVERTERS.flat_map { |converter| converter.validate(mail) }.compact
        unless error_messages.empty?
          raise ::SendGridActionMailerAdapter::ValidationError,
                "Validation error, #{error_messages}"
        end
      end

      def convert(mail)
        sendgrid_mail = ::SendGrid::Mail.new
        CONVERTERS.each do |converter|
          result = converter.convert(mail)
          converter.assign_attributes(sendgrid_mail, result)
        end
        sendgrid_mail
      end
    end
  end
end
