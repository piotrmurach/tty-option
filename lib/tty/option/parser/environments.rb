# frozen_string_literal: true

require_relative "../error_aggregator"
require_relative "../pipeline"

module TTY
  module Option
    class Parser
      class Environments
        # Create a command line env variables parser
        #
        # @param [Array<Environment>] environments
        #   the list of environment variables
        # @param [Hash] config
        #   the configuration settings
        #
        # @api public
        def initialize(environments, **config)
          @environments = environments
          @error_aggregator = ErrorAggregator.new(**config)
          @required_check = RequiredCheck.new(@error_aggregator)
          @parsed = {}
          @remaining = []
          @names = {}
          @arities = Hash.new(0)
          @multiplies = {}

          @environments.each do |env_arg|
            @names[env_arg.var.to_s] = env_arg
            @multiplies[env_arg.name] = env_arg if env_arg.multiple?

            if env_arg.default?
              case env_arg.default
              when Proc
                assign_envvar(env_arg, env_arg.default.())
              else
                assign_envvar(env_arg, env_arg.default)
              end
            elsif env_arg.required?
              @required_check << env_arg
            end
          end
        end

        # Read environment variable(s) from command line or ENV hash
        #
        # @param [Array<String>] argv
        # @param [Hash<String,Object>] env
        #
        # @api public
        def parse(argv, env)
          @argv = argv.dup
          @env = env

          loop do
            env_var, value = next_envvar
            break if env_var.nil?
            @required_check.delete(env_var)
            @arities[env_var.name] += 1

            if block_given?
              yield(env_var, value)
            end
            assign_envvar(env_var, value)
          end

          @environments.each do |env_arg|
            if (value = env[env_arg.var])
              @required_check.delete(env_arg)
              @arities[env_arg.name] += 1
              assign_envvar(env_arg, value)
            end
          end

          check_arity
          @required_check.()

          [@parsed, @remaining, @error_aggregator.errors]
        end

        private

        def next_envvar
          env_var, value = nil, nil

          while !@argv.empty? && !env_var?(@argv.first)
            @remaining << @argv.shift
          end

          if !@argv.empty?
            environment = @argv.shift
            name, val = environment.split("=")

            if (env_var = @names[name])
              if env_var.multi_argument? &&
                  !(consumed = consume_arguments).empty?
                value = [val] + consumed
              else
                value = val
              end
            end
          end

          [env_var, value]
        end

        # Consume multi argument
        #
        # @api private
        def consume_arguments(values: [])
          while (value = @argv.first) &&
            !option?(value) && !keyword?(value) && !env_var?(value)

            val = @argv.shift
            parts = val.include?("&") ? val.split(/&/) : [val]
            parts.each { |part| values << part }
          end

          values
        end

        # Check if values looks like option
        #
        # @api private
        def option?(value)
          !value.match(/^-./).nil?
        end

        # Check if value looks like keyword
        #
        # @param [String] value
        #
        # @return [Boolean]
        #
        # @api private
        def keyword?(value)
          !value.to_s.match(/^([^-=][\p{Ll}_\-\d]*)=([^=]+)/).nil?
        end

        # Check if value is an environment variable
        #
        # @return [Boolean]
        #
        # @api private
        def env_var?(value)
          !value.match(/^[\p{Lu}_\-\d]+=/).nil?
        end

        # @api private
        def assign_envvar(env_arg, val)
          value = Pipeline.process(env_arg, val)

          if env_arg.multiple?
            allowed = env_arg.arity < 0 || @arities[env_arg.name] <= env_arg.arity
            if allowed
              case value
              when Hash
                (@parsed[env_arg.name] ||=  {}).merge!(value)
              else
                Array(value).each do |v|
                  (@parsed[env_arg.name] ||=  []) << v
                end
              end
            else
              @remaining << "#{env_arg.var}=#{value}"
            end
          else
            @parsed[env_arg.name] = value
          end
        end

        # Check if parameter matches arity
        #
        # @raise [InvalidArity]
        #
        # @api private
        def check_arity
          @multiplies.each do |name, param|
            arity = @arities[name]
            min_arity = param.arity < 0 ? param.arity.abs - 1 : param.arity

            if arity < min_arity
              @error_aggregator.(InvalidArity.new(param, arity))
            end
          end
        end
      end # Environments
    end # Parser
  end # Option
end # TTY
