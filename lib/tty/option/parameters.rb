# frozen_string_literal: true

require "set"

module TTY
  module Option
    # A collection to hold all parameters
    class Parameters
      include Enumerable

      # Define a query for parameter types
      #
      # @api private
      def self.define_query(name)
        define_method(:"#{name}?") do
          !self.public_send(name).empty?
        end
      end

      # A list of arguments
      attr_reader :arguments

      # A list of keywords
      attr_reader :keywords

      # A list of environments
      attr_reader :environments

      # A list of options
      attr_reader :options

      # A list of all parameters
      attr_reader :list

      define_query :arguments
      define_query :keywords
      define_query :options
      define_query :environments

      # A parameters list
      #
      # @api private
      def initialize
        @arguments = []
        @environments = []
        @keywords = []
        @options = []
        @list = []

        @registered_names = Set.new
        @registered_shorts = Set.new
        @registered_longs = Set.new
      end

      # Add parameter
      #
      # @param [TTY::Option::Parameter] parameter
      #
      # @api public
      def <<(parameter)
        check_name_uniqueness!(parameter.name)

        if parameter.to_sym == :option
          check_short_option_uniqueness!(parameter.short_name)
          check_long_option_uniqueness!(parameter.long_name)
        end

        @list << parameter
        arr = instance_variable_get("@#{parameter.to_sym}s")
        arr.send :<<, parameter
        self
      end
      alias add <<

      # Delete a parameter from the list
      #
      # @example
      #   delete(:foo, :bar, :baz)
      #
      # @param [Array<Symbol>] names
      #   the names to delete
      #
      # @api public
      def delete(*names)
        deleted = []
        @list.delete_if { |p| names.include?(p.name) && (deleted << p) }
        @arguments = @arguments.difference(deleted)
        @environments = @environments.difference(deleted)
        @keywords = @keywords.difference(deleted)
        @options = @options.difference(deleted)
        @registered_names.subtract(names)
        @registered_shorts.replace(@options.map(&:short))
        @registered_longs.replace(@options.map(&:long))
        deleted
      end

      # Enumerate all parameters
      #
      # @api public
      def each(&block)
        if block_given?
          @list.each(&block)
        else
          to_enum(:each)
        end
      end

      # Make a deep copy of the list of parameters
      #
      # @api public
      def dup
        super.tap do |params|
          params.instance_variables.each do |var|
            dupped = DeepDup.deep_dup(params.instance_variable_get(var))
            params.instance_variable_set(var, dupped)
          end
        end
      end

      private

      # @api private
      def check_name_uniqueness!(name)
        if @registered_names.include?(name)
          raise ParameterConflict,
                "already registered parameter #{name.inspect}"
        else
          @registered_names << name
        end
      end

      # @api private
      def check_short_option_uniqueness!(short_name)
        return if short_name.empty?

        if @registered_shorts.include?(short_name)
          raise ParameterConflict,
                "already registered short option #{short_name}"
        else
          @registered_shorts << short_name
        end
      end

      # @api private
      def check_long_option_uniqueness!(long_name)
        return if long_name.empty?

        if @registered_longs.include?(long_name)
          raise ParameterConflict,
                "already registered long option #{long_name}"
        else
          @registered_longs << long_name
        end
      end
    end # Parameters
  end # Option
end # TTY
