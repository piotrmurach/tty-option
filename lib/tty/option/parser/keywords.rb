# frozen_string_literal: true

module TTY
  module Option
    class Parser
      class Keywords
        def initialize(keywords, **config)
          @keywords = keywords
          @errors = {}
          @parsed = {}
          @remaining = []
          @names = {}

          @keywords.each do |kwarg|
            @names[kwarg.name.to_s] = kwarg

            if kwarg.default?
              case kwarg.default
              when Proc
                assign_keyword(kwarg, kwarg.default.())
              else
                assign_keyword(kwarg, kwarg.default)
              end
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
            if block_given?
              yield(kwarg, value)
            end
            assign_keyword(kwarg, value)
          end

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
              (@parsed[kwarg.name] ||=  []) << value
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
