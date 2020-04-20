# frozen_string_literal: true

require "forwardable"

module TTY
  module Option
    class Params
      extend Forwardable

      def_delegators :@parameters,
        :keys, :key?, :has_key?, :member?, :value?, :has_value?, :empty?,
        :include?, :each_key, :each_value

      def initialize(parameters = {})
        @parameters = parameters
      end

      # Access a given value for a key
      #
      # @api public
      def [](key)
        @parameters[key.to_sym]
      end

      # Assign value to a key
      #
      # @api public
      def []=(key, value)
        @parameters[key.to_sym] = value
      end

      # Access a given value for a key
      #
      # @api public
      def fetch(key, *args, &block)
        value = self[key]
        return value unless value.nil?

        @parameters.fetch(key, *args, &block)
      end

      def merge(other_params)
        @parameters.merge(other_params)
      end

      def merge!(other_params)
        @parameters.merge!(other_params)
      end

      def ==(other)
        return false unless other.kind_of?(TTY::Option::Params)
        @parameters == other.to_h
      end
      alias eql? ==

      def hash
        @parameters.hash
      end

      def to_h
        @parameters.to_h
      end

      # String representation of this params
      #
      # @return [String]
      #
      # @api public
      def inspect
        "#<#{self.class}#{to_h.inspect}>"
      end

      # String representation of the parameters
      #
      # @return [String]
      #
      # @api public
      def to_s
        to_h.to_s
      end
    end # Params
  end # Option
end # TTY
