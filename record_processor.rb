# frozen_string_literal: true

require 'prime'
require_relative 'state'
require_relative 'services/validate_restrictions'
require_relative 'services/update_customer_limits'

# Class to procces one record from input.
# There is an update with guards, but without params validation.
# Use record_form to check before update
class RecordProcessor
  attr_accessor :state, :check_restrictions, :update_customer_limits

  include Dry::Monads[:result, :do]

  def initialize(
    state: State.new,
    check_restrictions: Services::ValidateRestrictions.new,
    update_customer_limits: Services::UpdateCustomerLimits.new
  )
    @state                  = state
    @check_restrictions     = check_restrictions
    @update_customer_limits = update_customer_limits
  end

  def call(record)
    can_be_processed = yield check_restrictions.call(record, state)

    update_customer_limits.call(record, state) if can_be_processed

    Success({ id: record.id, customer_id: record.customer_id, accepted: can_be_processed })
  end
end
