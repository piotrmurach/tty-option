# frozen_string_literal: true

module TTY
  module Option
    module ParamPermitted
      # Convert parameter value to another type
      #
      # @example
      #   param = Parameter::Argument.create(:foo, permit: %w[11 12 13])
      #   ParamPermitted[param, "12"] # => 12
      #
      # @api public
      def call(param, value)
        return value unless param.permit?

        if param.permit.include?(value)
          value
        else
          UnpermittedArgument.new(
            format("unpermitted argument %s for %s parameter",
                   value, param.name.inspect)
          )
        end
      end
      module_function :call

      alias :[] :call
      module_function :[]
    end # ParamPermitted
  end # Option
end # TTY
