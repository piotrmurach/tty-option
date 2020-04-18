# frozen_string_literal: true

require_relative "arity_check"
require_relative "required_check"
require_relative "../error_aggregator"
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
          @error_aggregator = ErrorAggregator.new(**config)
          @required_check = RequiredCheck.new(@error_aggregator)
          @arity_check = ArityCheck.new(@error_aggregator)
          @parsed = {}
          @remaining = []
          @names = {}
          @arities = Hash.new(0)

          @keywords.each do |kwarg|
            @names[kwarg.name.to_s] = kwarg
            @arity_check << kwarg if kwarg.multiple?

            if kwarg.default?
              case kwarg.default
              when Proc
                assign_keyword(kwarg, kwarg.default.())
              else
                assign_keyword(kwarg, kwarg.default)
              end
            elsif kwarg.required?
              @required_check << kwarg
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
            @required_check.delete(kwarg)
            @arities[kwarg.name] += 1

            if block_given?
              yield(kwarg, value)
            end
            assign_keyword(kwarg, value)
          end

          @arity_check.(@arities)
          @required_check.()

          [@parsed, @remaining, @error_aggregator.errors]
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
              if kwarg.multi_argument? &&
                 !(consumed = consume_arguments).empty?
                value = [val] + consumed
              else
                value = val
              end
            end
          end

          [kwarg, value]
        end

        # Consume multi argument
        #
        # @api private
        def consume_arguments(values: [])
          while (value = @argv.first) && !option?(value) && !keyword?(value)
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

        # @api private
        def assign_keyword(kwarg, val)
          value = Pipeline.process(kwarg, val)

          if kwarg.multiple?
            allowed = kwarg.arity < 0 || @arities[kwarg.name] <= kwarg.arity
            if allowed
              case value
              when Hash
                (@parsed[kwarg.name] ||= {}).merge!(value)
              else
                Array(value).each do |v|
                  (@parsed[kwarg.name] ||=  []) << v
                end
              end
            else
              @remaining << "#{kwarg.name}=#{value}"
            end
          else
            @parsed[kwarg.name] = value
          end
        end
      end # Keywords
    end # Parser
  end # Option
end # TTY
