# frozen_string_literal: true

require "forwardable"

module TTY
  module Option
    class AggregateErrors
      include Enumerable
      extend Forwardable

      def_delegators :@errors, :size, :empty?, :any?, :clear

      # Create an intance from the passed error objects
      #
      # @api public
      def initialize(errors = [])
        @errors = errors
      end

      # Add error
      #
      # @api public
      def add(error)
        @errors << error
        error
      end

      # Enumerate each error
      #
      # @example
      #   errors = AggregateErrors.new
      #   errors.each do |error|
      #     # instance of TTY::Option::Error
      #   end
      #
      # @api public
      def each(&block)
        @errors.each(&block)
      end

      # All error messages
      #
      # @example
      #   errors = AggregateErrors.new
      #   errors.add TTY::OptionInvalidArgument.new("invalid argument")
      #   errors.messages
      #   # => ["invalid argument"]
      #
      # @api public
      def messages
        map(&:message)
      end

      # Format errors for display in terminal
      #
      # @example
      #   errors = AggregateErrors.new
      #   errors.add TTY::OptionInvalidArgument.new("invalid argument")
      #   errors.summary
      #   # =>
      #   # Error: invalid argument
      #
      # @return [String]
      #
      # @api public
      def summary
        return "" if count.zero?

        output = []
        if messages.count == 1
          output << "Error: #{messages.first}"
        else
          output << "Errors:"
          messages.each do |message|
            output << "  * #{message}"
          end
        end
        output.join("\n")
      end
    end # AggregateErrors
  end # Option
end # TTY
