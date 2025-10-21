# frozen_string_literal: true

require_relative 'base_guard'
require_relative '../lib/date_comparisons'
require 'pry'

module Guards
  # Guard to check daily limits for a given record/customer
  class DailyLimits < BaseGuard
    using DateComparisons

    def call(record, state)
      customer         = state.get_customer(record.customer_id)
      last_record_date = customer[:last_record_date]
      used_funds       = record.time.same_date?(last_record_date) ? customer[:daily_limits] : 0

      used_funds + record.calculated_load_funds <= DEFAULT_DAILY_LIMIT
    end
  end
end
