# frozen_string_literal: true

require_relative "../error_aggregator"
require_relative "../pipeline"
require_relative "required_check"

module TTY
  module Option
    class Parser
      class Arguments
        # Create a command line arguments parser
        #
        # @param [Array<Argument>] arguments
        #   the list of arguments
        # @param [Hash] config
        #   the configuration settings
        #
        # @api public
        def initialize(arguments, **config)
          @arguments = arguments
          @error_aggregator = ErrorAggregator.new(**config)
          @required_check = RequiredCheck.new(@error_aggregator)
          @parsed = {}
          @remaining = []

          @defaults = {}
          @arguments.each do |arg|
            if arg.default?
              case arg.default
              when Proc
                @defaults[arg.name] = arg.default.()
              else
                @defaults[arg.name] = arg.default
              end
            elsif arg.required?
              @required_check << arg
            end
          end
        end

        # Read positional arguments from the command line
        #
        # @param [Array<String>] argv
        #
        # @return [Array<Hash, Array, Hash>]
        #   a list of parsed and unparsed arguments and errors
        #
        # @api private
        def parse(argv)
          @argv = argv.dup

          @arguments.each do |arg|
            values = next_argument(arg)
            @required_check.delete(arg) unless values.empty?

            assign_argument(arg, values)
          end

          while (val = @argv.shift)
            @remaining << val
          end

          @required_check.()

          [@parsed, @remaining, @error_aggregator.errors]
        end

        private

        # @api private
        def next_argument(arg)
          if arg.arity >= 0
            process_exact_arity(arg)
          else
            process_infinite_arity(arg)
          end
        end

        def process_exact_arity(arg)
          values = []
          arity = arg.arity

          while arity > 0
            break if @argv.empty?
            value = @argv.shift
            if argument?(value)
              values << value
              arity -= 1
            else
              @remaining << value
            end
          end

          if 0 < values.size && values.size < arg.arity &&
              Array(@defaults[arg.name]).size < arg.arity
            @error_aggregator.(InvalidArity.new(arg, values.size))
          end

          values
        end

        def process_infinite_arity(arg)
          values = []
          arity = arg.arity.abs - 1

          arity.times do |i|
            break if @argv.empty?
            value = @argv.shift
            if argument?(value)
              values << value
            else
              @remaining << value
            end
          end

          # consume remaining
          while (value = @argv.shift)
            if argument?(value)
              values << value
            else
              @remaining << value
            end
          end

          if values.size < arity && Array(@defaults[arg.name]).size < arity
            @error_aggregator.(InvalidArity.new(arg, values.size))
          end

          values
        end

        # Check if value is an argument
        #
        # @return [Boolean]
        #
        # @api private
        def argument?(value)
          !option?(value) && !keyword?(value) && !env_var?(value)
        end

        # Check if value is an environment variable
        #
        # @return [Boolean]
        #
        # @api private
        def env_var?(value)
          !value.match(/^[\p{Lu}_\-\d]+=/).nil?
        end

        # Check if value is an option
        #
        # @return [Boolean]
        #
        # @api private
        def option?(value)
          !value.match(/^-./).nil?
        end

        # Check if value is a keyword
        #
        # @return [Boolean]
        #
        # @api private
        def keyword?(value)
          !value.match(/^(.+)=(.+)/).nil?
        end

        # Assign argument to the parsed
        #
        # @param [Argument] arg
        # @param [Array] values
        #
        # @api private
        def assign_argument(arg, values)
          val = case values.size
                when 0
                  if arg.default?
                    case arg.default
                    when Proc
                      @defaults[arg.name]
                    else
                      @defaults[arg.name]
                    end
                  end
                when 1
                  values.first
                else
                  values
                end

          @parsed[arg.name] = Pipeline.process(arg, val)
        end
      end # Arguments
    end # Parser
  end # Option
end # TTY
