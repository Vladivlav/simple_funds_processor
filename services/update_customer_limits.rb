# frozen_string_literal: true

require_relative '../lib/date_comparisons'

module Services
  # Class check all the restrictions for the given record.
  # On sorting guard check there is a possible Failure response to stop program execution.
  # On successful sorting guard all other guards are checked
  # and always return Success object with boolean value wrapped inside
  class UpdateCustomerLimits
    using DateComparisons

    def call(record, state)
      customer = state.get_customer(record.customer_id)

      state.mark_first_prime_id_in_month!(record) if record.id.prime?
      state.reset_daily_limits!(record)           if record.time.new_date?(customer[:last_record_date])
      state.reset_monthly_limits!(record)         if record.time.new_month?(customer[:last_record_date])

      state.add_funds_to_customer_limits!(record)
    end
  end
end
