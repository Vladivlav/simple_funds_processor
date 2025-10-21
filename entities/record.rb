# frozen_string_literal: true

require 'dry/struct'
require_relative '../types'

# Class to implement entity for a one input line
class Record < Dry::Struct
  FUNDS_MONDAY_MULTIPLY = 2

  # include Types

  attribute :id, Types::Coercible::Integer
  attribute :customer_id, Types::Coercible::Integer
  attribute :load_amount, (Types::Coercible::String.constructor { |val| BigDecimal(val.to_s.gsub(/[^\d.]/, '')) })
  attribute :time, (Types::Nominal::DateTime.constructor { |string_date| Date.parse(string_date) })

  def calculated_load_funds
    time.wday == 1 ? load_amount * FUNDS_MONDAY_MULTIPLY : load_amount
  end
end
