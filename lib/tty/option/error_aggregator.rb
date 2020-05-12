# frozen_string_literal: true

require_relative "inflection"

module TTY
  module Option
    class ErrorAggregator
      include Inflection

      # Collected errors
      attr_reader :errors

      def initialize(errors = [], **config)
        @errors = errors
        @raise_on_parsing_error = config.fetch(:raise_on_parse_error) { false }
      end

      # Record or raise an error
      #
      # @param [TTY::Option::Error] error
      # @param [String] message
      #
      # @api public
      def call(error, message = nil)
        is_class = error.is_a?(Class)

        if @raise_on_parsing_error
          if is_class
            raise error, message
          else
            raise error
          end
        end

        if is_class
          @errors << [error, message]
        else
          @errors << error
        end
      end
    end # ErrorAggregator
  end # Option
end # TTY
