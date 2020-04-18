# frozen_string_literal: true

module TTY
  module Option
    Error = Class.new(StandardError)

    # Raised when an option matches more than one parameter option
    AmbiguousOption = Class.new(Error)

    # Raised when overriding already defined conversion
    ConversionAlreadyDefined = Class.new(Error)

    # Raised when argument doesn't match expected value
    class InvalidArgument < Error
      attr_reader :param

      def initialize(param_or_message, value = nil)
        if param_or_message.is_a?(Parameter)
          @param = param_or_message

          message = format(
            "value of `%s` fails validation rule for %s parameter",
            value,
            param.name.inspect
          )
        else
          message = param_or_message
        end

        super(message)
      end
    end

    # Raised when number of arguments doesn't match
    class InvalidArity < Error
      attr_reader :param

      def initialize(param_or_message, arity = nil)
        if param_or_message.is_a?(Parameter)
          @param = param_or_message
          prefix = param.arity < 0 ? "at least " : ""
          expected_arity = param.arity < 0 ? param.arity.abs - 1 : param.arity

          message = format(
            "expected %s %s to appear %s but appeared %s",
            param.to_sym,
            param.name.inspect,
            prefix + pluralize("time", expected_arity),
            pluralize("time", arity)
          )
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
    InvalidConversionArgument = Class.new(Error)

    # Raised when found unrecognized option
    InvalidOption = Class.new(Error)

    # Raised when permitted type is incorrect
    InvalidPermitted = Class.new(Error)

    # Raised when validation format is not supported
    InvalidValidation = Class.new(Error)

    # Raised when option requires an argument
    class MissingArgument  < Error
      attr_reader :param

      def initialize(param, switch_name = nil)
        @param = param
        name = switch_name.nil? ? param.name : switch_name
        message = "#{param.to_sym} #{name} requires an argument"

        super(message)
      end
    end

    # Raised when a parameter is required but not present
    class MissingParameter < Error
      attr_reader :param

      def initialize(param_or_message)
        if param_or_message.is_a?(Parameter)
          @param = param_or_message

          name = if param.respond_to?(:long_name)
            param.long? ? param.long_name : param.short_name
          else
            param.name
          end

          message =  "need to provide '#{name}' #{param.to_sym}"
        else
          message = param_or_message
        end

        super(message)
      end
    end

    # Raised when attempting to register already registered parameter
    ParameterConflict = Class.new(Error)

    # Raised when conversion type isn't registered
    UnsupportedConversion = Class.new(Error)

    # Raised when argument value isn't permitted
    class UnpermittedArgument < Error
      attr_reader :param

      def initialize(param_or_message, value = nil)
        if param_or_message.is_a?(Parameter)
          @param = param_or_message

          message = format(
            "unpermitted argument %s for %s parameter",
            value,
            param.name.inspect
          )
        else
          message = param_or_message
        end

        super(message)
      end
    end
  end # Option
end # TTY
