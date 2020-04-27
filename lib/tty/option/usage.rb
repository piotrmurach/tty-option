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

      # Display info before anything else in the usage help
      #
      # @api public
      def header(value = (not_set = true))
        if not_set
          @properties[:header]
        else
          @properties[:header] = value
        end
      end

      def header?
        @properties.key?(:header) && !@properties[:header].nil?
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

      # Collects usage examples
      #
      # @api public
      def example(*values)
        if values.empty?
          @properties.fetch(:example) { [] }
        else
          (@properties[:example] ||= []) << values
        end
      end

      def example?
        @properties.key?(:example) && !@properties[:example].empty?
      end

      # Display info after everyting else in the usage help
      #
      # @api public
      def footer(value = (not_set = true))
        if not_set
          @properties[:footer]
        else
          @properties[:footer] = value
        end
      end

      def footer?
        @properties.key?(:footer) && !@properties[:footer].nil?
      end
    end # Usage
  end # Option
end # TTY
