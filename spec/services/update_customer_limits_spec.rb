# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::UpdateCustomerLimits do
  subject { described_class.new }
  let(:record) { build :record, id: 17 }
  let(:state)  { instance_double(State) }

  before do
    allow(state).to receive(:get_customer).and_return({})
    allow(state).to receive(:mark_first_prime_id_in_month!)
    allow(state).to receive(:reset_daily_limits!)
    allow(state).to receive(:reset_monthly_limits!)
    allow(state).to receive(:add_funds_to_customer_limits!)
    subject.call(record, state)
  end

  describe '#call' do
    it 'updates customer last prime number data when record ID is a prime number' do
      expect(state).to have_received(:mark_first_prime_id_in_month!).with(record)
    end

    it 'resets daily limits if record date is different that last proceed record' do
      allow(record.time).to receive(:new_date?).and_return(true)
      expect(state).to have_received(:reset_daily_limits!).with(record)
    end

    it 'resets monthly limits if record month is different that last proceed record month' do
      allow(record.time).to receive(:new_month?).and_return(true)
      expect(state).to have_received(:reset_monthly_limits!).with(record)
    end

    it 'updates customers used daily and monthly funds stats' do
      expect(state).to have_received(:add_funds_to_customer_limits!).with(record)
    end
  end
end
