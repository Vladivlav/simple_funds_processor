# frozen_string_literal: true

require 'spec_helper'
require_relative '../input_processor'
require_relative '../forms/record_form'
require 'fileutils'

# rubocop:disable Metrics/BlockLength
describe 'InputProcessor' do
  subject(:call) do
    described_class.new(input_file: input_file, output_file: output_file, process_funds: mock_process_funds).call
  end
  let(:input_file)  { 'spec/tmp/test_input.txt' }
  let(:output_file) { 'output.txt' }
  let(:mock_process_funds) { -> { Success() } }

  before do
    FileUtils.mkdir_p('spec/tmp')
    FileUtils.rm_f(output_file)
  end

  context 'when records present in non-sorted way' do
    let(:input_file) { 'spec/tmp/test_unsorted_input.txt' }

    it 'raises an error' do
      expect { call }.to raise_error StandardError
    end
  end

  context 'when record from input file is not a valid JSON' do
    let(:input_file) { 'spec/tmp/test_non_json_records_input.txt' }

    it 'raises an error' do
      expect { call }.to raise_error StandardError
    end
  end

  context 'when JSON-record value does not have needed values' do
    let(:input_file) { 'spec/tmp/test_with_missing_required_fileds_input.txt' }

    it 'raises an error' do
      expect { call }.to raise_error StandardError
    end
  end

  context 'when all the check are passed successfully' do
    let(:source_input) { build :source_input, path: input_file }

    context 'when customer limits are reached' do
      let(:mock_process_funds) { -> { Success(true) } }

      it 'write the record to output with status accepted == true' do
      end
    end

    context 'when customer have not reached limits' do
      let(:mock_process_funds) { -> { Success(false) } }

      it 'write the record to output with status accepted == false' do
      end
    end
  end
end
# rubocop:enable Metrics/BlockLength
