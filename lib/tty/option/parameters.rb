# frozen_string_literal: true

require "set"

module TTY
  module Option
    # A collection to hold all parameters
    class Parameters
      # A list of arguments
      attr_reader :arguments

      # A list of keywords
      attr_reader :keywords

      # A list of environments
      attr_reader :environments

      # A list of options
      attr_reader :options

      # A list of all parameters
      attr_reader :all

      # A parameters list
      #
      # @api private
      def initialize
        @arguments = []
        @environments = []
        @keywords = []
        @options = []
        @all = []

        @registered_names = Set.new
        @registered_shorts = Set.new
        @registered_longs = Set.new
      end

      # Add parameter
      #
      # @api public
      def <<(parameter)
        check_name_uniqueness!(parameter.name)

        if parameter.to_sym == :option
          check_short_option_uniqueness!(parameter.short_name)
          check_long_option_uniqueness!(parameter.long_name)
        end

        @all << parameter
        arr = instance_variable_get("@#{parameter.to_sym}s")
        arr.send :<<, parameter
      end
      alias add <<

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
