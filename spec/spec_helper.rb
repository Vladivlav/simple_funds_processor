# frozen_string_literal: true

require 'rspec'
require 'factory_bot'
require 'json'
require 'dry/monads'
require_relative '../forms/record_form'
require_relative '../errors/invalid_record_format'
require_relative '../services/update_customer_limits'
require_relative '../services/process_funds'
require_relative '../services/line_parser'
require_relative 'support/shared_contexts/processing_failure_helpers'

# Configure FactoryBot
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  # Load all factories
  config.before(:suite) do
    FactoryBot.find_definitions
  end
end
