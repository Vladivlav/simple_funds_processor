# frozen_string_literal: true

require 'dry/types'
require 'bigdecimal'
require 'date'

# Strict types for load_funds and time values
module Types
  include Dry.Types

  CurrencyDecimal = Types::Coercible::String.constructor do |value|
    BigDecimal(value.to_s.gsub(/[^\d.]/, ''))
  end

  StrictDecimal = Types::Strict::Decimal
  StrictTime    = Types::Strict::Time
end
