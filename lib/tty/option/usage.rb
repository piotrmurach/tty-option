# frozen_string_literal: true

module TTY
  module Option
    class Usage
      # @api public
      def initialize(**properties)
        @properties = properties
      end

      # Program name for display in help and error messages
      #
      # @api public
      def program(name = (not_set = true), &block)
        if not_set
          @properties.fetch(:program) { ::File.basename($0, ".*") }
        else
          @properties[:program] = name
        end
      end

      # Main way to show how all parameters can be used
      #
      # @api public
      def banner(value = (not_set = true))
        if not_set
          @properties[:banner]
        else
          @properties[:banner] = value
        end
      end

      def banner?
        @properties.key?(:banner) && !@properties[:banner].nil?
      end

      # Description
      #
      # @api public
      def desc(value = (not_set = true))
        if not_set
          @properties[:desc]
        else
          @properties[:desc] = value
        end
      end

      def desc?
        @properties.key?(:desc) && !@properties[:desc].nil?
      end
    end # Usage
  end # Option
end # TTY
