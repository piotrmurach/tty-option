# frozen_string_literal: true

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
          @parsed = {}
          @errors = {}
          @remaining = []
          @names = {}

          @environments.each do |env_arg|
            @names[env_arg.var.to_s] = env_arg

            if env_arg.default?
              case env_arg.default
              when Proc
                assign_envvar(env_arg, env_arg.default.())
              else
                assign_envvar(env_arg, env_arg.default)
              end
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
            if block_given?
              yield(env_var, value)
            end
            assign_envvar(env_var, value)
          end

          @environments.each do |env_arg|
            if (value = env[env_arg.var])
              assign_envvar(env_arg, value)
            end
          end

          [@parsed, @remaining, @errors]
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
      end # Environments
    end # Parser
  end # Option
end # TTY
