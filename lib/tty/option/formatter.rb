# frozen_string_literal: true

module TTY
  module Option
    class Formatter
      SHORT_OPT_LENGTH = 4
      NEWLINE = "\n"
      ELLIPSIS = "..."
      SPACE = " "

      # @api public
      def self.help(parameters, usage)
        new(parameters, usage).help
      end

      attr_reader :indentation

      # Create a help formatter
      #
      # @param [Parameters]
      #
      # @api public
      def initialize(parameters, usage)
        @parameters = parameters
        @usage = usage
        @indent = 2
        @indentation = " " * 2
        @sections = {
          usage: "Usage:",
          options: "Options:",
          env: "Environment:",
          examples: "Examples:"
        }
      end

      # A formatted help usage information
      #
      # @return [String]
      #
      # @api public
      def help
        output = []

        output << @usage.header + NEWLINE if @usage.header?

        output << (@usage.banner? ? @usage.banner : format_usage)

        if @usage.desc?
          output << NEWLINE + format_description
        end

        if @parameters.options?
          output << NEWLINE + @sections[:options]
          output << format_options
        end

        if @parameters.environments?
          output << NEWLINE + @sections[:env]
          output << format_environment
        end

        if @usage.example?
          output << NEWLINE + @sections[:examples]
          output << format_examples
        end

        if @usage.footer?
          output << NEWLINE + @usage.footer
        end

        formatted = output.join(NEWLINE)
        formatted.end_with?(NEWLINE) ? formatted : formatted + NEWLINE
      end

      private

      # Provide a default usage banner
      #
      # @api private
      def format_usage
        output = []
        output << @sections[:usage] + SPACE
        output << @usage.program
        output << " [OPTIONS]" if @parameters.options?
        output << " [ENVIRONMENT]" if @parameters.environments?
        output << " #{format_arguments}" if @parameters.arguments?
        output << " #{format_keywords}" if @parameters.keywords?
        output.join
      end

      # Format arguments
      #
      # @api private
      def format_arguments
        return "" unless @parameters.arguments?

        @parameters.arguments.reduce([]) do |acc, arg|
          next acc if arg.hidden?

          acc << format_argument(arg)
        end.join(SPACE)
      end

      # Provide an argument summary
      #
      # @api private
      def format_argument(arg)
        arg_name = arg.name.to_s.upcase
        args = []
        if 0 < arg.arity
          args << "[" if arg.optional?
          args << arg_name
          (arg.arity - 1).times { args << " #{arg_name}" }
          args << "]" if arg.optional?
          args.join
        else
          (arg.arity.abs - 1).times { args << arg_name }
          args << "[#{arg_name}#{ELLIPSIS}]"
          args.join(SPACE)
        end
      end

      # Format keywords
      #
      # @api private
      def format_keywords
        return "" unless @parameters.keywords?

        @parameters.keywords.reduce([]) do |acc, kwarg|
          next acc if kwarg.hidden?

          acc << format_keyword(kwarg)
        end.join(SPACE)
      end

      # Provide a keyword summary
      #
      # @api private
      def format_keyword(kwarg)
        kwarg_name = kwarg.name.to_s.upcase
        conv_name = case kwarg.convert
                    when Proc, NilClass
                      kwarg_name
                    else
                      kwarg.convert.to_s.upcase
                    end
        if kwarg.required?
          "#{kwarg_name}=#{conv_name}"
        else
          "[#{kwarg_name}=#{conv_name}]"
        end
      end

      # Format multiline description
      #
      # @api private
      def format_description
        format_multiline(@usage.desc, "")
      end

      # Returns all the options formatted to fit 80 columns
      #
      # @return [String]
      #
      # @api private
      def format_options
        return "" if @parameters.options.empty?

        longest_option = @parameters.options.map(&:long)
                                    .compact.max_by(&:length).length
        any_short = @parameters.options.map(&:short).compact.any?
        ordered_options = @parameters.options.sort

        ordered_options.reduce([]) do |acc, option|
          next acc if option.hidden?
          acc << format_option(option, longest_option, any_short)
        end.join(NEWLINE)
      end

      # Format an option
      #
      # @api private
      def format_option(option, longest_length, any_short)
        line = []

        if any_short
          short_option = option.short? ? option.short_name : SPACE
          line << format("%#{SHORT_OPT_LENGTH}s", short_option)
        end

        # short & long option separator
        line << ((option.short? && option.long?) ? ", " : "  ")

        if option.long?
          if option.desc?
            line << format("%-#{longest_length}s", option.long)
          else
            line << option.long
          end
        else
          line << format("%-#{longest_length}s", SPACE)
        end

        if option.desc?
          line << "   #{option.desc}"
        end

        if option.permit?
          line << format(" (permitted: %s)", option.permit.join(","))
        end

        if (default = format_default(option))
          line << default
        end

        line.join
      end

      # Format default value
      #
      # @api private
      def format_default(param)
        return if !param.default? || [true, false].include?(param.default)

        if param.default.is_a?(String)
          format(" (default %p)", param.default)
        else
          format(" (default %s)", param.default)
        end
      end

      # @api private
      def format_environment
        longest_var = @parameters.environments.map(&:variable)
                                 .compact.max_by(&:length).length
        ordered_envs = @parameters.environments.sort

        ordered_envs.reduce([]) do |acc, env|
          next acc if env.hidden?

          acc << format_env(env, longest_var)
        end.join(NEWLINE)
      end

      # @api private
      def format_env(env, longest_var)
        line = []

        if env.desc?
          line << format("%s%-#{longest_var}s", indentation, env.variable.upcase)
          line << "   #{env.desc}"
        else
          line << format("%s%s", indentation, env.variable.upcase)
        end

        if (default = format_default(env))
          line << default
        end

        line.join
      end

      # Format examples section
      #
      # @api private
      def format_examples
        format_multiline(@usage.example, indentation)
      end

      # Format multiline content
      #
      # @api private
      def format_multiline(lines, indent)
        last_index = lines.size - 1
        lines.map.with_index do |line, i|
          line.map do |part|
            part.split(NEWLINE).map { |p| indent + p }.join(NEWLINE)
          end.join(NEWLINE) + (last_index != i ? NEWLINE : "")
        end.join(NEWLINE)
      end
    end # Formatter
  end # Option
end # TTY
