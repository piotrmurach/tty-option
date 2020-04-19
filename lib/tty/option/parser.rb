# frozen_string_literal: true

require_relative "parser/arguments"
require_relative "parser/environments"
require_relative "parser/keywords"
require_relative "parser/options"
require_relative "parser/param_types"
require_relative "pipeline"

module TTY
  module Option
    class Parser
      %w[
        arguments
        environments
        keywords
        options
      ].each do |name|
        define_method(name) do
          parameters.send(name)
        end
      end

      attr_reader :parameters

      attr_reader :config

      PARAMETER_PARSERS = {
        options: TTY::Option::Parser::Options,
        keywords: TTY::Option::Parser::Keywords,
        arguments: TTY::Option::Parser::Arguments,
        environments: TTY::Option::Parser::Environments
      }

      ARGUMENT_SEPARATOR = /^-{2,}$/.freeze

      def initialize(parameters, **config)
        @parameters = parameters
        @config = config
      end

      def parse(argv, env)
        argv = argv.dup
        params = {}
        errors = {}
        ignored = []

        # split argv into processable args and leftovers
        stop_index = argv.index { |arg| arg.match(ARGUMENT_SEPARATOR) }

        if stop_index
          ignored = argv.slice!(stop_index..-1)
          ignored.shift
        end

        PARAMETER_PARSERS.each do |name, parser_type|
          parser = parser_type.new(parameters.send(name), **config)
          if name == :environments
            parsed, argv, err = parser.parse(argv, env)
          else
            parsed, argv, err = parser.parse(argv)
          end
          params.merge!(parsed)
          errors.merge!(err)
        end

        argv += ignored unless ignored.empty?

        [params, argv, errors]
      end
    end # Parser
  end # Option
end # TTY
