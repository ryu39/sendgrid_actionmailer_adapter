# frozen_string_literal: true

require 'spec_helper'

RSpec.describe SendGridActionMailerAdapter do
  it 'has a version number' do
    expect(SendGridActionMailerAdapter::VERSION).not_to be nil
  end
end
