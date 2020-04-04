# frozen_string_literal: true

require_relative "../pipeline"

module TTY
  module Option
    class Parser
      class Options
        LONG_OPTION_RE = /^(--[^=]+)(\s+|=)?(.*)?$/.freeze

        SHORT_OPTION_RE = /^(-.)(.*)$/.freeze

        # Create a command line env variables parser
        #
        # @param [Array<Option>] options
        #   the list of options
        # @param [Hash] config
        #   the configuration settings
        #
        # @api public
        def initialize(options, **config)
          @options = options
          @raise_if_missing = config.fetch(:raise_if_missing) { true }
          @check_invalid_options = config.fetch(:check_invalid_options) { true }
          @parsed = {}
          @errors = {}
          @remaining = []
          @shorts = {}
          @longs = {}

          setup_opts
        end

        # Configure list of returned options
        #
        # @api private
        def setup_opts
          @options.each do |opt|
            @shorts[opt.short_name] = opt
            @longs[opt.long_name] = opt

            if opt.default?
              case opt.default
              when Proc
                assign_option(opt, opt.default.())
              else
                assign_option(opt, opt.default)
              end
            elsif !(opt.argument_optional? || opt.argument_required?)
              assign_option(opt, false)
            end
          end
        end

        # Read option(s) from command line
        #
        # @param [Array<String>] argv
        #
        # @api public
        def parse(argv)
          @argv = argv.dup

          loop do
            opt, value = next_option
            break if opt.nil?

            if block_given?
              yield(opt, value)
            else
              assign_option(opt, value)
            end
          end

          [@parsed, @remaining, @errors]
        end

        private

        # Get next option
        #
        # @api private
        def next_option
          opt, value = nil, nil

          while !@argv.empty? && !option?(@argv.first)
            @remaining << @argv.shift
          end

          return if @argv.empty?

          argument = @argv.shift

          if (matched = argument.match(LONG_OPTION_RE))
            long, sep, rest = matched[1..-1]
            opt, value = *process_double_option(long, sep, rest)
          elsif (matched = argument.match(SHORT_OPTION_RE))
            short, other_singles = *matched[1..-1]
            opt, value = *process_single_option(short, other_singles)
          end

          [opt, value]
        end

        # Process a double option
        #
        # @return [Array<Option, Object>]
        #   a list of option and its value
        #
        # @api private
        def process_double_option(long, sep, rest)
          opt, value = nil, nil

          if (opt = @longs[long])
            if opt.argument_required?
              if !rest.empty? || sep.to_s.include?("=")
                value = rest
                if opt.multi_argument? &&
                   !(consumed = consume_arguments(opt)).empty?
                  value = [rest] + consumed
                end
              elsif !@argv.empty?
                value = opt.multi_argument? ? consume_arguments(opt) : @argv.shift
              else
                record_error(MissingArgument,
                             "option #{long} requires an argument",
                             opt)
              end
            elsif opt.argument_optional?
              if !rest.empty?
                value = rest
                if opt.multi_argument? &&
                   !(consumed = consume_arguments(opt)).empty?
                  value = [rest] + consumed
                end
              elsif !@argv.empty?
                value = opt.multi_argument? ? consume_arguments(opt) : @argv.shift
              end
            else # boolean flag
              value = true
            end
          else
            # option stuck together with an argument or abbreviated
            matching_options = 0
            @longs.each_key do |key|
              if key.to_s.start_with?(long) || long.to_s.start_with?(key)
                opt = @longs[key]
                matching_options += 1
              end
            end

            if matching_options.zero?
              if @check_invalid_options
                record_error(InvalidOption, "invalid option #{long}")
              end
            elsif matching_options == 1
              value = long[opt.long_name.size..-1]
            else
              record_error(AmbiguousOption, "option #{long} is ambiguous")
            end
          end

          [opt, value]
        end

        # Process a single option
        #
        # @return [Array<Option, Object>]
        #   a list of option and its value
        #
        # @api private
        def process_single_option(short, other_singles)
          opt, value = nil, nil

          if (opt = @shorts[short])
            if opt.argument_required?
              if !other_singles.empty?
                value = other_singles
                if opt.multi_argument? &&
                   !(consumed = consume_arguments(opt)).empty?
                  value = [other_singles] + consumed
                end
              elsif !@argv.empty?
                value = opt.multi_argument? ? consume_arguments(opt) : @argv.shift
              else
                record_error(MissingArgument,
                             "option #{short} requires an argument",
                             opt)
              end
            elsif opt.argument_optional?
              if !other_singles.empty?
                value = other_singles
                if opt.multi_argument? &&
                   !(consumed = consume_arguments(opt)).empty?
                  value = [other_singles] + consumed
                end
              elsif !@argv.empty?
                value = opt.multi_argument? ? consume_arguments(opt) : @argv.shift
              end
            else # boolean flag
              if !other_singles.empty?
                @argv.unshift("-#{other_singles}")
              end
              value = true
            end
          elsif @check_invalid_options
            record_error(InvalidOption, "invalid option #{short}")
          end

          [opt, value]
        end

        # Consume multi argument
        #
        # @param [Option] opt
        #
        # @api private
        def consume_arguments(opt, values: [])
          while (value = @argv.first) && !option?(value)
            val = @argv.shift
            parts = val.include?("&") ? val.split(/&/) : [val]
            parts.each { |part| values << part }
          end

          values.size == 1 ? values.first : values
        end

        # Check if values looks like option
        #
        # @api private
        def option?(value)
          !value.match(/^-./).nil?
        end

        # @api private
        def record_error(type, message, opt = nil)
          if @raise_if_missing
            raise type, message
          end

          type_key = type.to_s.split("::").last
                         .gsub(/([a-z]+)([A-Z])/, "\\1_\\2")
                         .downcase.to_sym

          if opt
            (@errors[opt.name] ||= {}).merge!(type_key => message)
          else
            @errors[:invalid] = message
          end
        end

        # @api private
        def assign_option(opt, val)
          value = Pipeline.process(opt, val)

          if opt.multiple?
            case value
            when Hash
              (@parsed[opt.name] ||= {}).merge!(value)
            else
              Array(value).each do |v|
                (@parsed[opt.name] ||= []) << v
              end
            end
          else
            @parsed[opt.name] = value
          end
        end
      end # Options
    end # Parser
  end # Option
end # TTY
