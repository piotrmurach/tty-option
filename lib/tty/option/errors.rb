# frozen_string_literal: true

module TTY
  module Option
    Error = Class.new(StandardError)

    # Raised when an option matches more than one parameter option
    AmbiguousOption = Class.new(Error)

    # Raised when overriding already defined conversion
    ConversionAlreadyDefined = Class.new(Error)

    # Raised when found unrecognized parameter
    InvalidParameter = Class.new(Error)

    # Raised when permitted type is incorrect
    InvalidPermitted = Class.new(Error)

    # Raised when validation format is not supported
    InvalidValidation = Class.new(Error)

    # Raised when attempting to register already registered parameter
    ParameterConflict = Class.new(Error)

    # Raised when conversion type isn't registered
    UnsupportedConversion = Class.new(Error)

    # Raised when a parameter invariant is invalid
    class ParameterError < Error
      attr_accessor :param
    end

    # Raised when parameter argument doesn't match expected value
    class InvalidArgument < ParameterError
      MESSAGE = "value of `%<value>s` fails validation for %<name>s %<type>s"

      def initialize(param_or_message, value = nil)
        if param_or_message.is_a?(Parameter)
          @param = param_or_message

          message = format(MESSAGE,
                           value: value,
                           name: param.variable.inspect,
                           type: param.to_sym)
        else
          message = param_or_message
        end

        super(message)
      end
    end

    # Raised when number of parameter arguments doesn't match
    class InvalidArity < ParameterError
      MESSAGE = "%<type>s '%<name>s' should appear %<expect>s but appeared %<actual>s"

      def initialize(param_or_message, arity = nil)
        if param_or_message.is_a?(Parameter)
          @param = param_or_message
          prefix = param.arity < 0 ? "at least " : ""
          expected_arity = param.arity < 0 ? param.arity.abs - 1 : param.arity

          message = format(MESSAGE,
                           type: param.to_sym,
                           name: param.variable,
                           expect: prefix + pluralize("time", expected_arity),
                           actual: pluralize("time", arity))
        else
          message = param_or_message
        end

        super(message)
      end

      # Pluralize a noun
      #
      # @api private
      def pluralize(noun, count = 1)
        "#{count} #{noun}#{'s' unless count == 1}"
      end
    end

    # Raised when conversion provided with unexpected argument
    class InvalidConversionArgument < ParameterError
    end

    # Raised when option requires an argument
    class MissingArgument < ParameterError
      MESSAGE = "%<type>s %<name>s requires an argument"

      def initialize(param)
        @param = param
        message = format(MESSAGE, type: param.to_sym, name: param.variable)
        super(message)
      end
    end

    # Raised when a parameter is required but not present
    class MissingParameter < ParameterError
      MESSAGE = "need to provide '%<name>s' %<type>s"

      def initialize(param_or_message)
        if param_or_message.is_a?(Parameter)
          @param = param_or_message
          message = format(MESSAGE, name: param.variable, type: param.to_sym)
        else
          message = param_or_message
        end

        super(message)
      end
    end

    # Raised when argument value isn't permitted
    class UnpermittedArgument < ParameterError
      MESSAGE = "unpermitted value `%<value>s` for '%<name>s' %<type>s"

      def initialize(param_or_message, value = nil)
        if param_or_message.is_a?(Parameter)
          @param = param_or_message
          message = format(MESSAGE,
                           value: value,
                           name: param.variable,
                           type: param.to_sym)
        else
          message = param_or_message
        end

        super(message)
      end
    end
  end # Option
end # TTY
