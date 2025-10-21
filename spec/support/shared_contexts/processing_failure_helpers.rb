# frozen_string_literal: true

# spec/support/shared_contexts/processing_failure_helpers.rb

RSpec.shared_examples 'a processing failure case' do
  it { is_expected.to be_failure }

  it 'returns a Failure with the json_parse_error reason' do
    expect(subject.failure.first).to eq expected_error_name
    expect(subject.failure.last).to be_an expected_error_class
  end

  it 'does not call any next services' do
    mocks_not_called.each { |mock_obj| expect(mock_obj).not_to have_received(:call) }
  end
end

RSpec.shared_examples 'a success processing case' do
  it { is_expected.to be_success }

  it 'calls all necessary services in order' do
    expect(mock_json_parser).to have_received(:call).with(raw_json_input).ordered
    expect(mock_form).to have_received(:call).with(**json_input).ordered
    expect(mock_record_model).to have_received(:new).ordered
    expect(mock_record_processor).to have_received(:call).with(mock_record_instance).ordered
  end

  it 'it responses with the response of the last called service' do
    is_expected.to eq(mock_record_processor.call)
  end
end
