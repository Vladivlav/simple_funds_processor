# frozen_string_literal: true

require_relative '../lib/date_comparisons'

# Parent for all guards to store constants
class BaseGuard
  DEFAULT_DAILY_LIMIT   = 5_000
  DEFAULT_MONTHLY_LIMIT = 20_000

  using DateComparisons
end
