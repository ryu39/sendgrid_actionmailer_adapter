# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sendgrid_actionmailer_adapter/version'

Gem::Specification.new do |spec|
  spec.name          = 'sendgrid_actionmailer_adapter'
  spec.version       = SendGridActionMailerAdapter::VERSION
  spec.authors       = ['ryu39']
  spec.email         = ['dev.ryu39@gmail.com']

  spec.summary       = 'A ActionMailer adapter using SendGrid Web API v3'
  spec.description   = 'A ActionMailer adapter using SendGrid Web API v3.'
  spec.homepage      = 'https://github.com/ryu39/sendgrid_actionmailer_adapter'
  spec.license       = 'MIT'

  spec.files         = %w(LICENSE.txt) + Dir['lib/**/*.rb']
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_runtime_dependency 'sendgrid-ruby', '~> 4.0'

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'ryu39cop', '~> 0.49.1.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'webmock'
  spec.add_development_dependency 'mail'
  spec.add_development_dependency 'actionmailer'
end
