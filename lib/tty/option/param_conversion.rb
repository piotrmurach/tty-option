# frozen_string_literal: true

require_relative "conversions"
require_relative "result"

module TTY
  module Option
    module ParamConversion
      # Convert parameter value to another type
      #
      # @example
      #   param = Parameter::Argument.create(:foo, convert: :int)
      #   ParamConversion[param, "12"] # => 12
      #
      # @api public
      def call(param, value)
        return Result.success(value) unless param.convert?

        case cast = param.convert
        when Proc
          Result.success(cast.(value))
        else
          Result.success(Conversions[cast].(value))
        end
      rescue InvalidConversionArgument
        Result.failure(InvalidConversionArgument.new(param, value))
      end
      module_function :call

      alias :[] :call
      module_function :[]
    end # ParamConversion
  end # Option
end # TTY
