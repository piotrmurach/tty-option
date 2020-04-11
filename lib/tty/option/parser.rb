# frozen_string_literal: true

require_relative "parser/arguments"
require_relative "parser/environments"
require_relative "parser/keywords"
require_relative "parser/options"
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

      PARAMETER_PARSERS = {
        options: TTY::Option::Parser::Options,
        keywords: TTY::Option::Parser::Keywords,
        arguments: TTY::Option::Parser::Arguments,
        environments: TTY::Option::Parser::Environments
      }

      def initialize(parameters)
        @parameters = parameters
      end

      def parse(argv, env)
        argv = argv.dup
        params = {}

        PARAMETER_PARSERS.each do |name, parser_type|
          parser = parser_type.new(parameters.send(name))
          if name == :environments
            parsed, argv = parser.parse(argv, env)
          else
            parsed, argv = parser.parse(argv)
          end
          params.merge!(parsed)
        end

        params
      end
    end # Parser
  end # Option
end # TTY
