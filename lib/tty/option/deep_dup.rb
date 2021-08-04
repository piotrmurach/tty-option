# frozen_string_literal: true

module TTY
  module Option
    module DeepDup
      NONDUPLICATABLE = [
        Symbol, TrueClass, FalseClass, NilClass, Numeric, Method
      ].freeze

      # Duplicate an object making a deep copy
      #
      # @param [Object] object
      #
      # @api public
      def self.deep_dup(object)
        case object
        when *NONDUPLICATABLE then object
        when Hash   then deep_dup_hash(object)
        when Array  then deep_dup_array(object)
        else object.dup
        end
      end

      # A deep copy of hash
      #
      # @param [Hash] object
      #
      # @api private
      def self.deep_dup_hash(object)
        object.each_with_object({}) do |(key, val), new_hash|
          new_hash[deep_dup(key)] = deep_dup(val)
        end
      end

      # A deep copy of array
      #
      # @param [Array] object
      #
      # @api private
      def self.deep_dup_array(object)
        object.each_with_object([]) do |val, new_array|
          new_array << deep_dup(val)
        end
      end
    end # DeepDup
  end # Option
end # TTY
