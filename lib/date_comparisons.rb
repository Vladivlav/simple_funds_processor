# frozen_string_literal: true

require 'date'

# Module to extend existing Date class.
# Needs are to compare Dates by month-year or day-month-year
module DateComparisons
  refine Date do
    def same_date?(other)
      other && day == other.day && month == other.month && year == other.year
    end

    def same_month?(other)
      other && month == other.month && year == other.year
    end

    def new_date?(other)
      !same_date?(other)
    end

    def new_month?(other)
      !same_month?(other)
    end
  end
end
