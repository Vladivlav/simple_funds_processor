# frozen_string_literal: true

require 'dry-validation'
require 'date'

# Form for record input to validate params and generate record entity
class RecordForm < Dry::Validation::Contract
  ONLY_DIGITS_REGEX = /\A\d+\z/.freeze
  LOAD_AMOUNT_REGEX = /\A(?:USD)?\$\d+(?:\.\d{1,2})?\z/.freeze
  ISO8601_UTC_REGEX = /\A\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z\z/.freeze

  params do
    required(:id).filled(:string, format?: /\A\d+\z/)
    required(:customer_id).filled(:string, format?: ONLY_DIGITS_REGEX)
    required(:load_amount).filled(:string, format?: LOAD_AMOUNT_REGEX)
    required(:time).filled(:string, format?: ISO8601_UTC_REGEX)
  end
end
