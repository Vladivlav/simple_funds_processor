# frozen_string_literal: true

require 'prime'
require_relative '../lib/date_comparisons'

module Guards
  # Class to check that record ID is a first prime number during month
  class PrimeNumber < BaseGuard
    using DateComparisons

    def call(record, state)
      return true unless record.id.prime?
      return true if     state.prime_number_date.nil?

      !state.prime_number_date.same_month?(record.time)
    end
  end
end
