# frozen_string_literal: true

module TTY
  module Option
    module ParamValidation
      # Validate parameter value against validation rule
      #
      # @example
      #   param = Parameter::Option.create(:foo, validate: '\d+')
      #   ParamValidation[param, "12"] # => "12"
      #
      # @api public
      def call(param, values)
        return values unless param.validate?

        result = Array(values).reduce([]) do |acc, value|
          valid = case param.validate
                  when Proc
                    param.validate.(value)
                  when Regexp
                    !param.validate.match(value.to_s).nil?
                  end

          if valid
            acc << value
          else
            acc << TTY::Option::InvalidArgument.new(
                     format("value of `%s` fails validation rule for %s parameter",
                            value, param.name.inspect))
          end
          acc
        end
        result.size <= 1 ? result.first : result
      end
      module_function :call

      alias :[] :call
      module_function :[]
    end # ParamValidation
  end # Option
end # TTY
