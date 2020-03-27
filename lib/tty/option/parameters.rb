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

      # A list of all parameters
      attr_reader :all

      # A parameters list
      #
      # @api private
      def initialize
        @arguments = []
        @environments = []
        @keywords = []
        @all = []

        @registered_names = Set.new
      end

      # Add parameter
      #
      # @api public
      def <<(parameter)
        if @registered_names.include?(parameter.name)
          raise ParameterConflict,
                "already registered parameter #{parameter.name.inspect}"
        else
          @registered_names << parameter.name
        end

        @all << parameter
        arr = instance_variable_get("@#{parameter.to_sym}s")
        arr.send :<<, parameter
      end
      alias add <<
    end # Parameters
  end # Option
end # TTY
