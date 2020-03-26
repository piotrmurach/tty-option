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

      # Specify environment variable
      #
      # @example
      #   EDITOR=vim
      #
      # @api public
      def environment(name, **settings, &block)
        environments << Parameter::Environment.create(name, **settings, &block)
      end
      alias env environment

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

      def environments
        @environments ||= []
      end

      def keywords
        @keywords ||= []
      end
    end # DSL
  end # Option
end # TTY
