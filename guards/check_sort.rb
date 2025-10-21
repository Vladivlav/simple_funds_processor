# frozen_string_literal: true

module Guards
  # Class implements logic to check records time order.
  # To compare we use last proceed record time for a customer and compare to imcome record time.
  # Service return boolean value.
  class CheckSort
    def call(record, state)
      last_record_date = state.get_customer(record.customer_id)[:last_record_date]

      last_record_date.nil? || last_record_date <= record.time
    end
  end
end
