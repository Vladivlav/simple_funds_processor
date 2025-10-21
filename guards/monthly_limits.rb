# frozen_string_literal: true

require_relative 'base_guard'
require_relative '../lib/date_comparisons'

module Guards
  # Guard to check monthly limits for a given record/customer
  class MonthlyLimits < BaseGuard
    using DateComparisons

    def call(record, state)
      customer         = state.get_customer(record.customer_id)
      last_record_date = customer[:last_record_date]

      if last_record_date&.same_month?(record.time)
        customer[:monthly_limits] + record.calculated_load_funds <= DEFAULT_MONTHLY_LIMIT
      else
        record.calculated_load_funds <= DEFAULT_MONTHLY_LIMIT
      end
    end
  end
end
