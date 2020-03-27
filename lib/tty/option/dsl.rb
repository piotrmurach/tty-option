# frozen_string_literal: true

require_relative "parameter/argument"
require_relative "parameter/environment"
require_relative "parameter/keyword"
require_relative "parameters"

module TTY
  module Option
    module DSL
      # Specify an argument
      #
      # @api public
      def argument(name, **settings, &block)
        parameters << Parameter::Argument.create(name.to_sym, **settings, &block)
      end

      # Specify environment variable
      #
      # @example
      #   EDITOR=vim
      #
      # @api public
      def environment(name, **settings, &block)
        parameters << Parameter::Environment.create(name.to_sym, **settings, &block)
      end
      alias env environment

      # Specify a keyword
      #
      # @example
      #   foo=bar
      #
      # @api public
      def keyword(name, **settings, &block)
        parameters << Parameter::Keyword.create(name.to_sym, **settings, &block)
      end

      # Holds all parameters
      #
      # @api public
      def parameters
        @parameters ||= Parameters.new
      end
    end # DSL
  end # Option
end # TTY
