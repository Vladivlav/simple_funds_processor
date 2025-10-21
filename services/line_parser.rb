# frozen_string_literal: true

require 'dry/monads'

module Services
  # Class implements service to wrap JSON.parse result into monad.
  # In case of valid raw_json servide returns parsed data wrapped into Success objects
  # In case of invalid json data format service returns Failure object with custom Error
  class LineParser
    include Dry::Monads[:result]

    def call(raw_json)
      parsed_json = JSON.parse(raw_json)
      Success(parsed_json)
    rescue JSON::ParserError
      Failure([:json_parse_error, Errors::InvalidRecordFormat.new])
    end
  end
end
