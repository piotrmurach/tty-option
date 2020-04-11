# frozen_string_literal: true

require_relative "../pipeline"

module TTY
  module Option
    class Parser
      class Keywords
        # Create a command line keywords parser
        #
        # @param [Array<Keyword>] keywords
        #   the list of keywords
        # @param [Hash] config
        #   the configuration settings
        #
        # @api public
        def initialize(keywords, **config)
          @keywords = keywords
          @raise_if_missing = config.fetch(:raise_if_missing) { true }
          @errors = {}
          @parsed = {}
          @remaining = []
          @names = {}
          @required = []
          @arities = Hash.new(0)
          @multiplies = {}

          @keywords.each do |kwarg|
            @names[kwarg.name.to_s] = kwarg
            @multiplies[kwarg.name] = kwarg if kwarg.multiple?

            if kwarg.default?
              case kwarg.default
              when Proc
                assign_keyword(kwarg, kwarg.default.())
              else
                assign_keyword(kwarg, kwarg.default)
              end
            elsif kwarg.required?
              @required << kwarg
            end
          end
        end

        # Read keyword arguments from the command line
        #
        # @api public
        def parse(argv)
          @argv = argv.dup

          loop do
            kwarg, value = next_keyword
            break if kwarg.nil?
            @required.delete(kwarg)
            @arities[kwarg.name] += 1

            if block_given?
              yield(kwarg, value)
            end
            assign_keyword(kwarg, value)
          end

          check_arity
          check_required

          [@parsed, @remaining, @errors]
        end

        private

        # Get next keyword
        #
        # @api private
        def next_keyword
          kwarg, value = nil, nil

          while !@argv.empty? && !keyword?(@argv.first)
            @remaining << @argv.shift
          end

          if @argv.empty?
            return
          else
            keyword = @argv.shift
          end

          if (match = keyword.match(/([^=-]+)=([^=]+)/))
            _, name, val = *match.to_a

            if (kwarg = @names[name])
              value = val
            end
          end

          [kwarg, value]
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

        # @api private
        def assign_keyword(kwarg, value)
          if kwarg.multiple?
            if kwarg.arity < 0 || (@parsed[kwarg.name] || []).size < kwarg.arity
              (@parsed[kwarg.name] ||=  []) << Pipeline.process(kwarg, value)
            else
              @remaining << "#{kwarg.name}=#{value}"
            end
          else
            @parsed[kwarg.name] = Pipeline.process(kwarg, value)
          end
        end

        # Record or raise an error
        #
        # @api private
        def record_error(error, message, param = nil)
          is_class = error.is_a?(Class)

          if @raise_if_missing
            if is_class
              raise error, message
            else
              raise error
            end
          end

          type_name = is_class ? error.name : error.class.name
          type_key = type_name.to_s.split("::").last
                         .gsub(/([a-z]+)([A-Z])/, "\\1_\\2")
                         .downcase.to_sym
          if param
            (@errors[param.name] ||= {}).merge!(type_key => message)
          else
            @errors[:invalid] = message
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
              record_error(error, error.message, param)
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
            record_error(MissingParameter,
                         "need to provide '#{name}' #{param.to_sym}", param)
          end
        end
      end # Keywords
    end # Parser
  end # Option
end # TTY
