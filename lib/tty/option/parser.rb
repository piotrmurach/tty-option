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

      def initialize(parameters)
        @parameters = parameters
      end

      def parse(argv, env)
        argv = argv.dup
        params = {}

        opts_parser = TTY::Option::Parser::Options.new(options)
        parsed, unparsed_argv = opts_parser.parse(argv)

        params.merge!(parsed)

        keyword_parser = TTY::Option::Parser::Keywords.new(keywords)
        parsed, unparsed_argv = keyword_parser.parse(unparsed_argv)

        params.merge!(parsed)

        arg_parser = TTY::Option::Parser::Arguments.new(arguments)
        parsed, unparsed_argv = arg_parser.parse(unparsed_argv)

        params.merge!(parsed)

        env_parser = TTY::Option::Parser::Environments.new(environments)
        parsed, unparsed_argv = env_parser.parse(unparsed_argv, env)

        params.merge!(parsed)

        params
      end
    end # Parser
  end # Option
end # TTY
