# frozen_string_literal: true

require 'simplecov'
SimpleCov.start do
  add_filter('spec')
end

require 'webmock/rspec'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'sendgrid_actionmailer_adapter'
