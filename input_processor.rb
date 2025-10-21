# frozen_string_literal: true

require_relative 'services/process_funds'

# Main class to proccess input file with data and to genefrate output file
class InputProcessor
  attr_reader :input_file, :output_file_name, :process_funds

  OUTPUT_FILE_NAME = 'output.txt'
  INPUT_FILE_NAME  = 'input.txt'

  def initialize(input_file: INPUT_FILE_NAME, output_file: OUTPUT_FILE_NAME, process_funds: Services::ProcessFunds.new)
    @input_file       = input_file
    @output_file_name = output_file
    @process_funds    = process_funds
  end

  def call
    clear_output_file_if_exists

    File.open(output_file_name, 'w') do |output_file|
      File.open(input_file).each_line do |input_line|
        process_funds.call(input_line).either(
          ->(success_value)   { output_file.puts(success_value.to_json) },
          ->(failure_details) { raise StandardError, failure_details }
        )
      end
    end
  end

  private

  def clear_output_file_if_exists
    File.delete(output_file_name) if File.exist?(output_file_name)
  end
end
