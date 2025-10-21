# frozen_string_literal: true

module Errors
  # Top-level comment
  class UnsortedRecords < StandardError
    ERROR_MESSAGE = 'Records must be present in sorted list by ASC'

    def initialize(message = ERROR_MESSAGE)
      super(message)
    end
  end
end
