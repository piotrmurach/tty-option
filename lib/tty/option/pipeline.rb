# frozen_string_literal: true

require_relative "param_conversion"
require_relative "param_permitted"
require_relative "param_validation"

module TTY
  module Option
    class Pipeline
      def self.process(param, value)
        new(param, value)
          .next(ParamConversion)
          .next(ParamPermitted)
          .next(ParamValidation)
          .value
      end

      def initialize(param, value)
        @param = param
        @value = value
        freeze
      end

      def next(callable)
        result = callable[@param, @value]
        error = Array(result).find { |res| res.is_a?(Error) }
        if error
          raise error
        end
        self.class.new(@param, result)
      end

      def value
        @value
      end
    end # Pipeline
  end # Option
end # TTY
