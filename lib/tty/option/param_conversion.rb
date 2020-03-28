# frozen_string_literal: true

require_relative "conversions"

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
        return value unless param.convert?

        case cast = param.convert
        when Proc
          cast.(value)
        else
          Conversions[cast].(value)
        end
      end
      module_function :call

      alias :[] :call
      module_function :[]
    end # ParamConversion
  end # Option
end # TTY
