# frozen_string_literal: true

require_relative '../guards/check_sort'
require_relative '../guards/daily_limits'
require_relative '../guards/monthly_limits'
require_relative '../guards/prime_number'
require_relative '../errors/unsorted_records'

module Services
  # Class check all the restrictions for the given record.
  # On sorting guard check there is a possible Failure response to stop program execution.
  # On successful sorting guard all other guards are checked
  # and always return Success object with boolean value wrapped inside
  class ValidateRestrictions
    attr_reader :sorting_guard, :daily_limits_guard, :monthly_limits_guard, :prime_number_guard

    include Dry::Monads[:result]

    def initialize(
      sorting_guard: ::Guards::CheckSort.new,
      daily_limits_guard: ::Guards::DailyLimits.new,
      monthly_limits_guard: ::Guards::MonthlyLimits.new,
      prime_number_guard: ::Guards::PrimeNumber.new
    )
      @sorting_guard        = sorting_guard
      @daily_limits_guard   = daily_limits_guard
      @monthly_limits_guard = monthly_limits_guard
      @prime_number_guard   = prime_number_guard
    end

    def call(record, state)
      return Failure([:unsorted_records, Errors::UnsortedRecords.new]) unless sorting_guard.call(record, state)

      Success(
        prime_number_guard.call(record, state) &&
        daily_limits_guard.call(record, state) &&
        monthly_limits_guard.call(record, state)
      )
    end
  end
end
