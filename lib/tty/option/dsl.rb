# frozen_string_literal: true

require_relative "parameter/argument"
require_relative "parameter/environment"
require_relative "parameter/keyword"

module TTY
  module Option
    module DSL
      # Specify an argument
      #
      # @api public
      def argument(name, **settings, &block)
        arguments << Parameter::Argument.create(name.to_sym, **settings, &block)
      end

      # Specify a keyword
      #
      # @example
      #   foo=bar
      #
      # @api public
      def keyword(name, **settings, &block)
        keywords << Parameter::Keyword.create(name.to_sym, **settings, &block)
      end

      def arguments
        @arguments ||= []
      end

      def keywords
        @keywords ||= []
      end
    end # DSL
  end # Option
end # TTY
