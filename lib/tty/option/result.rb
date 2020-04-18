# frozen_string_literal: true

module TTY
  module Option
    # A monad that respresents success and failure conditions
    class Result
      # Wrap a value in a success monad
      #
      # @api public
      def self.success(value)
        Success.new(value)
      end

      # Wrap a value in a failure monad
      #
      # @api public
      def self.failure(value)
        Failure.new(value)
      end

      attr_reader :value

      attr_reader :error

      def success?
        is_a?(Success)
      end

      def failure?
        is_a?(Failure)
      end

      class Success < Result
        def initialize(value)
          @value = value
        end
      end

      class Failure < Result
        def initialize(error)
          @error = error
        end
      end
    end
  end
end
