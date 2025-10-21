# frozen_string_literal: true

module Errors
  # Top-level comment
  class InvalidRecordFormat < StandardError
    ERROR_MESSAGE = 'Can not parse records from file. Some records are in invalid JSON format'

    def initialize(message = ERROR_MESSAGE)
      super(message)
    end
  end
end
