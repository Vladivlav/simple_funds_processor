# frozen_string_literal: true

require 'spec_helper'
require_relative '../record_processor'

RSpec.describe RecordProcessor do
  include Dry::Monads[:do, :result]

  subject(:process_record!) do
    described_class.new(
      state: state,
      check_restrictions: fake_check_restrictions,
      update_customer_limits: fake_update_customer_limits
    ).call(record)
  end

  let(:state)             { double(State, get_customer: {}) }
  let(:record)            { build :record, { customer_id: 1, load_amount: 'USD$122.98', time: DateTime.now.to_s } }
  let(:accepted)          { fake_check_restrictions.call(nil, nil).value! }
  let(:expected_response) { { id: record.id, customer_id: record.customer_id, accepted: accepted } }

  let(:fake_update_customer_limits) { double(Services::UpdateCustomerLimits, call: true) }

  before { process_record! }

  describe '#call' do
    context 'when sorting order has broken' do
      let(:fake_check_restrictions) { ->(_, _) { Failure() } }

      it { is_expected.to be_failure }
    end

    context 'when limits are reached' do
      let(:fake_check_restrictions) { ->(_, _) { Success(false) } }

      it { is_expected.to be_success }

      it 'contains boolean false value wrapped' do
        expect(process_record!.value!).to eq expected_response
      end

      it 'does not update customer limits' do
        expect(fake_update_customer_limits).not_to have_received(:call)
      end
    end

    context 'when limits are not reached' do
      let(:fake_check_restrictions) { ->(_, _) { Success(true) } }

      it { is_expected.to be_success }

      it 'contains boolean true value wrapped' do
        expect(process_record!.value!).to eq expected_response
      end

      it 'update customer limits with record funds' do
        expect(fake_update_customer_limits).to have_received(:call).with(record, state)
      end
    end
  end
end
