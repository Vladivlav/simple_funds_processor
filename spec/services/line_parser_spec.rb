# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Services::LineParser do
  subject(:line_parser) { described_class.new }
  let(:result)          { line_parser.call(raw_data) }

  describe '#call' do
    context 'when income data cant be parsed as JSON' do
      let(:raw_data) { '{{}}' }

      it { expect(result).to be_failure }

      specify 'returning value contains custom error message' do
        expect(result.failure.last.message).to eq(Errors::InvalidRecordFormat::ERROR_MESSAGE)
      end

      specify 'returning value contains custom error' do
        expect(result.failure.last).to be_a(Errors::InvalidRecordFormat)
      end
    end

    context 'when income data succesfully parsed as JSON' do
      let(:raw_data) { '{"id":"20510","customer_id":"18","load_amount":"$526.05","time":"2000-01-01T20:27:20Z"}' }

      it { expect(result).to be_success }

      it 'returns income data as a hash object wrapped into Success object' do
        expect(result.value!).to eq(JSON.parse(raw_data))
      end
    end
  end
end
