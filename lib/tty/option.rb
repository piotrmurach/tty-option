# frozen_string_literal: true

require_relative "option/dsl"
require_relative "option/parser"
require_relative "option/version"

module TTY
  module Option
    Error = Class.new(StandardError)

    # Raised when number of arguments doesn't match
    InvalidArity = Class.new(Error)

    # Enhance object with command line option parsing
    #
    # @api public
    def self.included(base)
      base.module_eval do
        include Interface
        extend DSL
      end
    end

    module Interface
      def params
        @params ||= {}
      end

      def parse(argv = ARGV, env = ENV)
        parser = Parser.new(self.class.arguments, self.class.keywords,
                            self.class.environments)
        @params = parser.parse(argv, env)
      end
    end
  end # Option
end # TTY
