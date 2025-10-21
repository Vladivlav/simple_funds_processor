# frozen_string_literal: true

require_relative '../spec_helper'
require_relative '../../guards/prime_number'
require_relative '../../state'
require 'date'

# rubocop:disable Metrics/BlockLength
RSpec.describe Guards::PrimeNumber do
  let(:guard) { described_class.new }
  let(:record) { build :record, { id: id, customer_id: 1, load_amount: 100, time: time } }
  let(:id) { 7 }
  let(:state) { State.new }

  describe '#call' do
    subject(:call) { guard.call(record, state) }

    context 'when no prime number record exists' do
      let(:time) { DateTime.now.to_s }

      it { expect(call).to be true }
    end

    context 'when prime number record exists for different month' do
      before { state.prime_number_date = DateTime.now }

      context 'when record is in different month' do
        let(:id) { 11 }
        let(:time) { (DateTime.now << 1).to_s }

        it { expect(call).to be true }
      end

      context 'when record is in different month of different year' do
        let(:id) { 13 }
        let(:time) { (DateTime.now << 12).to_s }

        it { expect(call).to be true }
      end
    end

    context 'when prime number record exists for same month and year' do
      before { state.prime_number_date = DateTime.now }

      context 'when record is in same month and year' do
        let(:id) { 17 }
        let(:time) { DateTime.now.to_s }

        it { expect(call).to be false }
      end

      context 'when record is on same day' do
        let(:id) { 19 }
        let(:time) { DateTime.now.to_s }

        it { expect(call).to be false }
      end
    end

    context 'edge cases' do
      context 'when record crosses year boundary' do
        before { state.prime_number_date = Date.new(DateTime.now.year, 12, 31) }

        let(:id) { 23 }
        let(:time) { Date.new(DateTime.now.year + 1, 1, 1).to_s }

        it { expect(call).to be true }
      end

      context 'when record crosses month boundary' do
        before { state.prime_number_date = Date.new(DateTime.now.year, DateTime.now.month, -1) }

        let(:id) { 29 }
        let(:time) { (Date.new(DateTime.now.year, DateTime.now.month, -1) + 1).to_s }

        it { expect(call).to be true }
      end

      context 'when record crosses leap year month boundary' do
        before { state.prime_number_date = Date.new(2024, 2, 29) }

        let(:id) { 31 }
        let(:time) { Date.new(2024, 3, 1).to_s }

        it { expect(call).to be true }
      end
    end

    context 'with different prime customer IDs' do
      before { state.prime_number_date = DateTime.now }

      let(:time) { DateTime.now.to_s }
      let(:prime_ids) { [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47] }

      context 'when record is in same month' do
        it 'returns false for any prime customer ID' do
          prime_ids.each do |prime_id|
            rec = build :record, { id: prime_id, customer_id: 1, load_amount: 100, time: time }
            result = guard.call(rec, state)
            expect(result).to be false
          end
        end
      end

      context 'when record is in different month' do
        let(:different_time) { time << 1 }

        it 'returns true for any prime customer ID' do
          prime_ids.each do |prime_id|
            rec = build :record, { customer_id: prime_id, load_amount: 100, time: different_time }
            result = guard.call(rec, state)
            expect(result).to be true
          end
        end
      end
    end

    context 'with non-prime customer IDs' do
      before { state.prime_number_date = DateTime.now }

      let(:time) { DateTime.now.to_s }
      let(:non_prime_ids) { [1, 4, 6, 8, 9, 10, 12, 14, 15, 16, 18, 20, 21, 22, 24] }

      it 'returns true regardless of date' do
        non_prime_ids.each do |non_prime_id|
          rec = build :record, { customer_id: non_prime_id, load_amount: 100, time: time }
          result = guard.call(rec, state)
          expect(result).to be true
        end
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
