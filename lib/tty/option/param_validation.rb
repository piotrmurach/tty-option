# frozen_string_literal: true

require_relative "result"

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
        return Result.success(values) unless param.validate?

        errors = []

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
            errors << TTY::Option::InvalidArgument.new(param, value)
          end
          acc
        end

        if errors.empty?
          Result.success(result.size <= 1 ? result.first : result)
        else
          Result.failure(errors)
        end
      end
      module_function :call

      alias [] call
      module_function :[]
    end # ParamValidation
  end # Option
end # TTY
