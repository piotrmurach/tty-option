# frozen_string_literal: true

require_relative "../pipeline"

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
          @raise_if_missing = config.fetch(:raise_if_missing) { true }
          @errors = {}
          @parsed = {}
          @remaining = []
          @required = []

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
              @required << arg
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
            @required.delete(arg) unless values.empty?

            assign_argument(arg, values)
          end

          while (val = @argv.shift)
            @remaining << val
          end

          check_required

          [@parsed, @remaining, @errors]
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
            record_error(InvalidArity, format(
              "expected argument %s to appear %d times but appeared %d times",
              arg.name.inspect, arg.arity, values.size), arg)
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
            record_error(InvalidArity, format(
              "expected argument %s to appear at least %d times but appeared %d times", arg.name.inspect, arity, values.size, arg))
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

        # Record or raise an error
        #
        # @api private
        def record_error(type, message, arg = nil)
          if @raise_if_missing
            raise type, message
          end

          type_key = type.to_s.split("::").last
                         .gsub(/([a-z]+)([A-Z])/, "\\1_\\2")
                         .downcase.to_sym

          if arg
            (@errors[arg.name] ||= {}).merge!(type_key => message)
          else
            @errors[:invalid] = message
          end
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

        # Check if required parameters are provided
        #
        # @raise [MissingParameter]
        #
        # @api private
        def check_required
          return if @required.empty?

          @required.each do |param|
            name = if param.respond_to?(:long_name)
              param.long? ? param.long_name : param.short_name
            else
              param.name
            end
            record_error(MissingParameter,
                         "need to provide '#{name}' #{param.to_sym}", param)
          end
        end
      end # Arguments
    end # Parser
  end # Option
end # TTY
