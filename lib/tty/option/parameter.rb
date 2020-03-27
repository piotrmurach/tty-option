# frozen_string_literal: true

require_relative "arity_dsl"

module TTY
  module Option
    class Parameter
      include ArityDSL

      def self.create(name, **settings, &block)
        new(name, **settings, &block)
      end

      attr_reader :name

      attr_reader :settings

      def initialize(name, **settings, &block)
        @name = name
        @settings = settings

        if @settings.key?(:arity)
          arity(@settings[:arity])
        end

        instance_eval(&block) if block_given?
      end

      def default_arity
        1
      end

      def arity(value = (not_set = true))
        if not_set
          @settings.fetch(:arity) { default_arity }
        else
          @settings[:arity] = check_arity(value)
        end
      end

      # Check if multiple occurrences are allowed
      #
      # @return [Boolean]
      #
      # @api public
      def multiple?
        arity < 0 || arity.abs > 1
      end

      def default(value = (not_set = true))
        if not_set
          @settings[:default]
        else
          @settings[:default] = value
        end
      end
      alias defaults default

      def default?
        @settings.key?(:default) && !@settings[:default].nil?
      end

      def optional
        @settings[:required] = false
      end

      def optional?
        !required?
      end

      def required
        @settings[:required] = true
      end

      def required?
        @settings.fetch(:required) { true }
      end

      def to_sym
        self.class.name.to_s.split(/::/).last.downcase.to_sym
      end

      def to_h
        @settings.dup
      end

      private

      # @api private
      def check_arity(value)
        if value.nil?
          raise InvalidArity, "expects an integer value"
        end

        if value.to_s =~ %r{\*|any}
          value = -1
        end
        value = value.to_i

        if value.zero?
          raise InvalidArity, "cannot be zero"
        end
        value
      end
    end # Parameter
  end # Option
end # TTY
