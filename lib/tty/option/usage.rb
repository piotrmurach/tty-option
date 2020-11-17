# frozen_string_literal: true

require_relative "deep_dup"

module TTY
  module Option
    class Usage
      # Create an usage
      #
      # @api public
      def self.create(**properties, &block)
        new(**properties, &block)
      end

      # Create an usage
      #
      # @api public
      def initialize(**properties, &block)
        @properties = {}
        properties.each do |key, val|
          case key.to_sym
          when :desc, :description
            key, val = :desc, [Array(val)]
          when :header, :footer
            val = [Array(val)]
          when :example, :examples
            key, val = :example, [Array(val)]
          end
          @properties[key.to_sym] = val
        end

        instance_eval(&block) if block_given?
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

      # Action name for display in help and error messages
      #
      # @api public
      def command(*values)
        if values.empty?
          @properties.fetch(:command) { [] }
        else
          @properties[:command] = []
          values.each { |val| @properties[:command] << val }
        end
      end
      alias commands command

      # Remove default commands
      #
      # @api public
      def no_command
        @properties[:command] = []
      end

      # Check for command definition
      #
      # @return [Boolean]
      #
      # @api public
      def command?
        @properties.key?(:command) && !@properties[:command].empty?
      end

      # Display info before anything else in the usage help
      #
      # @api public
      def header(*values)
        if values.empty?
          @properties.fetch(:header) { [] }
        else
          (@properties[:header] ||= []) << values
        end
      end

      def header?
        @properties.key?(:header) && !@properties[:header].empty?
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
      def desc(*values)
        if values.empty?
          @properties.fetch(:desc) { [] }
        else
          (@properties[:desc] ||= []) << values
        end
      end
      alias description desc

      def desc?
        @properties.key?(:desc) && !@properties[:desc].empty?
      end
      alias description? desc?

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
      alias examples example

      def example?
        @properties.key?(:example) && !@properties[:example].empty?
      end
      alias examples? example?

      # Display info after everyting else in the usage help
      #
      # @api public
      def footer(*values)
        if values.empty?
          @properties.fetch(:footer) { [] }
        else
          (@properties[:footer] ||= []) << values
        end
      end

      def footer?
        @properties.key?(:footer) && !@properties[:footer].empty?
      end

      # Return a hash of this usage properties
      #
      # @return [Hash] the names and values of this usage
      #
      # @api public
      def to_h(&block)
        if block_given?
          @properties.each_with_object({}) do |(key, val), acc|
            k, v = *block.(key, val)
            acc[k] = v
          end
        else
          DeepDup.deep_dup(@properties)
        end
      end
    end # Usage
  end # Option
end # TTY
