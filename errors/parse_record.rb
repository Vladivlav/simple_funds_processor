# frozen_string_literal: true

module Errors
  # Top-level comment
  class ParseRecord < StandardError
    ERROR_MESSAGE = 'Invalid data format. Please, use NDJSON.'

    def initialize(message = ERROR_MESSAGE)
      super(message)
    end
  end
end
