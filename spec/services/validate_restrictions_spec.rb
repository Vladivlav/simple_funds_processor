# frozen_string_literal: true

require 'spec_helper'

RSpec.shared_examples 'Success validation response' do
  it 'respond with Success object' do
    expect(subject.call(record, state)).to be_success
  end

  it 'respond with expected_value' do
    expect(subject.call(record, state).value!).to be expected_value
  end
end

RSpec.describe Services::ValidateRestrictions do
  subject do
    described_class.new(
      sorting_guard: mock_sorting_guard,
      daily_limits_guard: mock_daily_limits_guard,
      monthly_limits_guard: mock_monthly_limits_guard,
      prime_number_guard: mock_prime_number_guard
    )
  end
  let(:record) { build :record }
  let(:state)  { instance_double(State) }

  let(:mock_sorting_guard) { instance_double(::Guards::CheckSort, call: true) }
  let(:mock_daily_limits_guard) { instance_double(::Guards::DailyLimits, call: true) }
  let(:mock_monthly_limits_guard) { instance_double(::Guards::MonthlyLimits, call: true) }
  let(:mock_prime_number_guard) { instance_double(::Guards::PrimeNumber, call: true) }

  context 'when sorting guard failed' do
    let(:mock_sorting_guard) { instance_double(::Guards::CheckSort, call: false) }

    it { expect(subject.call(record, state)).to be_failure }
  end

  context 'when sorting guard passed' do
    let(:mock_sorting_guard) { instance_double(::Guards::CheckSort, call: true) }

    context 'when prime number guard failed' do
      let(:expected_value) { false }
      let(:mock_prime_number_guard) { instance_double(::Guards::PrimeNumber, call: false) }

      it_behaves_like 'Success validation response'
    end

    context 'when monthly limits guard failed' do
      let(:expected_value) { false }
      let(:mock_daily_limits_guard) { instance_double(::Guards::MonthlyLimits, call: false) }

      it_behaves_like 'Success validation response'
    end

    context 'when daily limits guard failed' do
      let(:expected_value) { false }
      let(:mock_prime_number_guard) { instance_double(::Guards::DailyLimits, call: false) }

      it_behaves_like 'Success validation response'
    end

    context 'when all guards have passed' do
      let(:expected_value) { true }
      let(:mock_sorting_guard) { instance_double(::Guards::CheckSort, call: true) }
      let(:mock_daily_limits_guard) { instance_double(::Guards::DailyLimits, call: true) }
      let(:mock_monthly_limits_guard) { instance_double(::Guards::MonthlyLimits, call: true) }
      let(:mock_prime_number_guard) { instance_double(::Guards::PrimeNumber, call: true) }

      it_behaves_like 'Success validation response'
    end
  end
end
