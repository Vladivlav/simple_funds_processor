# frozen_string_literal: true

require_relative 'lib/date_comparisons'

# Class to store statistics about daily monthly funds usage
class State
  attr_accessor :customers, :prime_number_date

  using DateComparisons

  def initialize
    @customers         = Hash.new { |h, k| h[k] = { daily_limits: 0, monthly_limits: 0, last_record_date: nil } }
    @prime_number_date = nil
  end

  def get_customer(customer_id)
    @customers[customer_id]
  end

  def reset_daily_limits!(record)
    customer = get_customer(record.customer_id)

    customer[:daily_limits] = 0
  end

  def reset_monthly_limits!(record)
    customer = get_customer(record.customer_id)

    customer[:monthly_limits] = 0
  end

  def mark_first_prime_id_in_month!(record)
    @prime_number_date = record.time
  end

  def add_funds_to_customer_limits!(record)
    customer = get_customer(record.customer_id)

    customer[:daily_limits]     += record.calculated_load_funds
    customer[:monthly_limits]   += record.calculated_load_funds
    customer[:last_record_date] = record.time
  end
end
