# frozen_string_literal: true

require_relative '../record_processor'

module Services
  # Class implements a service to procees raw json custom finds data.
  # It parses raw_json into ruby hash.
  # Then it validates parsed JSON with record form.
  # Then it creates new Record object and then get a result of processing.
  class ProcessFunds
    attr_reader :form, :json_parser, :record_processor, :record_model

    include Dry::Monads[:do, :result]

    def initialize(
      json_parser: Services::LineParser.new,
      form: RecordForm.new,
      record_model: Record,
      record_processor: RecordProcessor.new
    )
      @json_parser      = json_parser
      @form             = form
      @record_model     = record_model
      @record_processor = record_processor
    end

    def call(raw_json)
      parsed_attrs         = yield json_parser.call(raw_json)
      validated_attributes = yield convert_form_result_to_monad(form.call(parsed_attrs))
      record               = record_model.new(**validated_attributes)

      record_processor.call(record)
    end

    private

    def convert_form_result_to_monad(form_validation_result)
      return Success(form_validation_result.to_h) if form_validation_result.success?

      formatted_errors = form_validation_result.errors.to_h.values.flatten.join(', ')
      Failure([:validation_error, StandardError.new("Validation failed: #{formatted_errors}")])
    end
  end
end
