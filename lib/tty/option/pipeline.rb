# frozen_string_literal: true

require_relative "param_conversion"
require_relative "param_validation"

module TTY
  module Option
    class Pipeline
      def self.process(param, value)
        new(param, value)
          .next(ParamConversion)
          .next(ParamValidation)
          .value
      end

      def initialize(param, value)
        @param = param
        @value = value
        freeze
      end

      def next(callable)
        self.class.new(@param, callable[@param, @value])
      end

      def value
        @value
      end
    end # Pipeline
  end # Option
end # TTY
