# frozen_string_literal: true

require_relative "option/parser"
require_relative "option/version"

module TTY
  module Option
    Error = Class.new(StandardError)

    # Raised when number of arguments doesn't match
    InvalidArity = Class.new(Error)
  end # Option
end # TTY
