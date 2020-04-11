# frozen_string_literal: true

require_relative "option/arity_dsl"
require_relative "option/conversions"
require_relative "option/dsl"
require_relative "option/errors"
require_relative "option/parser"
require_relative "option/version"

module TTY
  module Option
    # Enhance object with command line option parsing
    #
    # @api public
    def self.included(base)
      base.module_eval do
        include Interface
        extend ArityDSL
        extend DSL
      end
    end

    module Interface
      def parameters
        @parameters ||= {}
      end
      alias :params :parameters

      def parse(argv = ARGV, env = ENV)
        parser = Parser.new(self.class.parameters)
        @parameters = parser.parse(argv, env)
      end
    end
  end # Option
end # TTY
