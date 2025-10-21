# frozen_string_literal: true

require 'spec_helper'
require_relative '../support/shared_contexts/processing_failure_helpers'

RSpec.describe Services::ProcessFunds do
  include Dry::Monads[:result]

  subject do
    described_class.new(
      form: mock_form,
      json_parser: mock_json_parser,
      record_processor: mock_record_processor,
      record_model: mock_record_model
    ).call(raw_json_input)
  end

  let(:mock_json_parser)      { instance_double(Services::LineParser, call: Success()) }
  let(:mock_record_processor) { instance_double(RecordProcessor, call: Success()) }
  let(:mock_record_model)     { class_double(Record, new: mock_record_instance) }
  let(:mock_form)             { instance_double(RecordForm, call: true) }

  let(:mock_record_instance)  { build :record }
  let(:json_input)            { JSON.parse(raw_json_input) }
  let(:raw_json_input) do
    %({"id":"7528","customer_id":"273","load_amount":"$5862.58","time":"2000-01-01T07:09:34Z"})
  end

  before { subject }

  describe '#call' do
    context 'when input cannot be parsed as JSON' do
      let(:mock_json_parser)     { instance_double(Services::LineParser, call: Failure([:json_parse_error, Errors::InvalidRecordFormat.new])) }
      let(:expected_error_name)  { mock_json_parser.call(raw_json_input).failure.first }
      let(:expected_error_class) { mock_json_parser.call(raw_json_input).failure.last.class }
      let(:mocks_not_called)     { [mock_form, mock_record_processor] }

      it_behaves_like 'a processing failure case'
    end

    context 'when input is a JSON and contains invalid data (form validation fails)' do
      let(:mock_form)            { instance_double(RecordForm, call: instance_double(Dry::Validation::Result, success?: false, errors: { '1': 1, '2': 2 })) }
      let(:expected_error_name)  { :validation_error }
      let(:expected_error_class) { StandardError }
      let(:mocks_not_called)     { [mock_record_processor] }

      it_behaves_like 'a processing failure case'
    end

    context 'when input is valid' do
      let(:mock_record_model)     { class_double(Record, new: mock_record_instance) }
      let(:mock_record_processor) { instance_double(RecordProcessor, call: Success()) }
      let(:mock_json_parser)      { instance_double(Services::LineParser, call: Success(JSON.parse(raw_json_input))) }
      let(:mocked_form_result)    { instance_double(Dry::Validation::Result, success?: true, to_h: JSON.parse(raw_json_input).symbolize_keys) }
      let(:mock_form)             { instance_double(RecordForm, call: mocked_form_result) }

      it_behaves_like 'a success processing case'
    end
  end
end
