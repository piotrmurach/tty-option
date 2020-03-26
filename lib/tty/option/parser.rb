# frozen_string_literal: true

require_relative "parser/arguments"
require_relative "parser/environments"
require_relative "parser/keywords"

module TTY
  module Option
    class Parser

      attr_reader :arguments

      attr_reader :keywords

      def initialize(arguments, keywords)
        @arguments = arguments
        @keywords = keywords
      end

      def parse(argv, env)
        argv = argv.dup
        params = {}

        keyword_parser = TTY::Option::Parser::Keywords.new(keywords)
        parsed, unparsed_argv = keyword_parser.parse(argv)

        params.merge!(parsed)

        arg_parser = TTY::Option::Parser::Arguments.new(arguments)
        parsed, unparsed_argv = arg_parser.parse(unparsed_argv)

        params.merge!(parsed)

        params
      end
    end # Parser
  end # Option
end # TTY
