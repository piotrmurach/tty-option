# frozen_string_literal: true

module TTY
  module Option
    module ParamValidation
      def call(param, values)
        return values unless param.validate?

        Array(values).each do |value|
          result = case param.validate
                   when Proc
                     param.validate.(value)
                   when Regexp
                     !param.validate.match(value.to_s).nil?
                   end

          result || raise(TTY::Option::InvalidValidation.new(
            format("value of %s fails validation rule for %s parameter",
                   value.inspect, param.name.inspect)
          ))
        end
        values
      end
      module_function :call

      alias :[] :call
      module_function :[]
    end # ParamValidation
  end # Option
end # TTY
