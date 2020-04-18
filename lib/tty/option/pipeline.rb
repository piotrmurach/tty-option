# frozen_string_literal: true

require_relative "param_conversion"
require_relative "param_permitted"
require_relative "param_validation"

module TTY
  module Option
    class Pipeline
      PROCESSORS = [
        ParamConversion,
        ParamPermitted,
        ParamValidation
      ]

      # Create a param processing pipeline
      #
      # @api private
      def initialize(error_aggregator)
        @error_aggregator = error_aggregator
      end

      # Process param value through conditions
      #
      # @api public
      def call(param, value)
        PROCESSORS.each do |processor|
          result = processor[param, value]
          error = Array(result).find { |res| res.is_a?(Error) }
          if error
            @error_aggregator.(error)
            value = nil
          else
            value = result
          end
        end
        value
      end
    end # Pipeline
  end # Option
end # TTY
