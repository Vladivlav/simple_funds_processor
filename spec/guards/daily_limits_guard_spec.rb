# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../guards/daily_limits'
require_relative '../../guards/check_sort'
require_relative '../../state'
require 'date'

# rubocop:disable Metrics/BlockLength
RSpec.describe Guards::DailyLimits do
  let(:guard)  { described_class.new }
  let(:record) { build :record, { customer_id: 1, load_amount: load_amount, time: Date.new(2025, 7, 20).to_s } }
  let(:state)  { State.new }

  describe '#call' do
    subject(:call) { guard.call(record, state) }

    context 'when it is the first fund record during the day' do
      before { state.customers[record.customer_id][:daily_limits] = 0 }

      context 'when load_amount more than max daily limits' do
        let(:load_amount) { BaseGuard::DEFAULT_DAILY_LIMIT + 1 }

        it { expect(call).to be false }
      end

      context 'when load_amount less than max daily limits' do
        let(:load_amount) { BaseGuard::DEFAULT_DAILY_LIMIT - 1 }

        it { expect(call).to be true }
      end
    end

    context 'when customer has proceeded records this day' do
      before do
        record = build :record, { customer_id: 1, load_amount: 'USD$123', time: Date.new(2025, 7, 20).to_s }
        Services::UpdateCustomerLimits.new.call(record, state)
      end

      context 'when load_amount more than max monthly limits without current limits' do
        let(:load_amount) { BaseGuard::DEFAULT_DAILY_LIMIT - 123 + 1 }

        it { expect(call).to be false }
      end

      context 'when load_amount less than max monthly limits without current limits' do
        let(:load_amount) { BaseGuard::DEFAULT_DAILY_LIMIT - 123 * 2 - 1 }

        it { expect(call).to be true }
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
