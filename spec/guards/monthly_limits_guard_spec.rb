# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../guards/monthly_limits'
require_relative '../../guards/check_sort'
require_relative '../../state'
require 'date'
require 'pry'

# rubocop:disable Metrics/BlockLength
RSpec.describe Guards::MonthlyLimits do
  let(:guard)  { described_class.new }
  let(:record) { build :record, { customer_id: 1, load_amount: load_amount, time: Date.new(2025, 7, 20).to_s } }
  let(:state)  { State.new }

  describe '#call' do
    subject(:call) { guard.call(record, state) }

    context 'when it is the first fund record in the month' do
      before { state.customers[record.customer_id][:monthly_limits] = 0 }

      context 'when load_amount more than max monthly limits' do
        let(:load_amount) { BaseGuard::DEFAULT_MONTHLY_LIMIT + 1 }

        it { expect(call).to be false }
      end

      context 'when load_amount less than max monthly limits' do
        let(:load_amount) { BaseGuard::DEFAULT_MONTHLY_LIMIT - 1 }

        it { expect(call).to be true }
      end
    end

    context 'when customer has proceeded records this month' do
      before do
        record = build :record, { customer_id: 1, load_amount: 'USD$123', time: Date.new(2025, 7, 19).to_s }
        Services::UpdateCustomerLimits.new.call(record, state)
      end

      context 'when load_amount more than max monthly limits without current limits' do
        let(:load_amount) { BaseGuard::DEFAULT_MONTHLY_LIMIT - 123 + 1 }

        it do
          expect(call).to be false
        end
      end

      context 'when load_amount less than max monthly limits without current limits' do
        let(:load_amount) { BaseGuard::DEFAULT_MONTHLY_LIMIT - 123 * 2 - 1 }

        it { expect(call).to be true }
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
