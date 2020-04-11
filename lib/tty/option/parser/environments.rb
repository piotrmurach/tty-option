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
          @parsed = {}
          @remaining = []
          @names = {}
          @arities = Hash.new(0)
          @required = []
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
              @required << env_arg
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
            @required.delete(env_var)
            @arities[env_var.name] += 1

            if block_given?
              yield(env_var, value)
            end
            assign_envvar(env_var, value)
          end

          @environments.each do |env_arg|
            if (value = env[env_arg.var])
              @required.delete(env_arg)
              @arities[env_arg.name] += 1
              assign_envvar(env_arg, value)
            end
          end

          check_arity
          check_required

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
              value = val
            end
          end

          [env_var, value]
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
        def assign_envvar(env_arg, value)
          if env_arg.multiple?
            if env_arg.arity < 0 || (@parsed[env_arg.name] || []).size < env_arg.arity
              (@parsed[env_arg.name] ||=  []) << Pipeline.process(env_arg, value)
            else
              @remaining << "#{env_arg.var}=#{value}"
            end
          else
            @parsed[env_arg.name] = Pipeline.process(env_arg, value)
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

            if 0 < param.arity.abs && arity < param.arity.abs
              error = InvalidArity.new(param, arity)
              @error_aggregator.(error, error.message, param)
            end
          end
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
            @error_aggregator.(MissingParameter,
                               "need to provide '#{name}' #{param.to_sym}", param)
          end
        end
      end # Environments
    end # Parser
  end # Option
end # TTY
