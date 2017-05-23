# frozen_string_literal: true

require 'sendgrid_actionmailer_adapter/version'
require 'sendgrid_actionmailer_adapter/configuration'
require 'sendgrid_actionmailer_adapter/delivery_method'

module SendGridActionMailerAdapter
  def self.configure(&block)
    ::SendGridActionMailerAdapter::Configuration.configure(&block)
  end
end
