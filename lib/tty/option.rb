# frozen_string_literal: true

require_relative "option/arity_dsl"
require_relative "option/conversions"
require_relative "option/dsl"
require_relative "option/parser"
require_relative "option/version"

module TTY
  module Option
    Error = Class.new(StandardError)

    # Raised when an option matches more than one parameter option
    AmbiguousOption = Class.new(Error)

    # Raised when overriding already defined conversion
    ConversionAlreadyDefined = Class.new(Error)

    # Raised when argument doesn't match expected value
    InvalidArgument = Class.new(Error)

    # Raised when number of arguments doesn't match
    InvalidArity = Class.new(Error)

    # Raised when conversion provided with unexpected argument
    InvalidConversionArgument = Class.new(Error)

    # Raised when found unrecognized option
    InvalidOption = Class.new(Error)

    # Raised when permitted type is incorrect
    InvalidPermitted = Class.new(Error)

    # Raised when validation format is not supported
    InvalidValidation = Class.new(Error)

    # Raised when option requires an argument
    MissingArgument = Class.new(Error)

    # Raised when attempting to register already registered parameter
    ParameterConflict = Class.new(Error)

    # Raised when conversion type isn't registered
    UnsupportedConversion = Class.new(Error)

    # Raised when argument value isn't permitted
    UnpermittedArgument = Class.new(Error)

    # Enhance object with command line option parsing
    #
    # @api public
    def self.included(base)
      base.module_eval do
        include Interface
        extend ArityDSL
        extend DSL
      end
    end

    module Interface
      def params
        @params ||= {}
      end

      def parse(argv = ARGV, env = ENV)
        parser = Parser.new(self.class.parameters)
        @params = parser.parse(argv, env)
      end
    end
  end # Option
end # TTY
