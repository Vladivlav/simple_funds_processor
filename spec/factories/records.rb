# frozen_string_literal: true

require_relative '../../entities/record'

FactoryBot.define do
  factory :record do
    id { '1' }
    customer_id { '1' }
    load_amount { 'USD$1001.12' }
    time { DateTime.now.to_s }

    initialize_with { new(id: id, customer_id: customer_id, load_amount: load_amount, time: time) }
  end
end
