# frozen_string_literal: true

require_relative "sections"
require_relative "usage_wrapper"

module TTY
  module Option
    class Formatter
      include UsageWrapper

      SHORT_OPT_LENGTH = 4
      DEFAULT_WIDTH = 80
      NEWLINE = "\n"
      ELLIPSIS = "..."
      SPACE = " "

      DEFAULT_PARAM_DISPLAY = ->(str) { str.to_s.upcase }
      DEFAULT_ORDER = ->(params) { params.sort }
      NOOP_PROC = ->(param) { param }
      DEFAULT_NAME_SELECTOR = ->(param) { param.variable }

      # @api public
      def self.help(parameters, usage, **config, &block)
        new(parameters, usage, **config).help(&block)
      end

      attr_reader :width

      # Create a help formatter
      #
      # @param [Parameters]
      #
      # @api public
      def initialize(parameters, usage, param_display: DEFAULT_PARAM_DISPLAY,
                     width: DEFAULT_WIDTH, order: DEFAULT_ORDER, indent: 0)
        @parameters = parameters
        @usage = usage
        @param_display = param_display
        @order = order
        @width = width
        @indent = indent
        @param_indent = indent + 2
        @section_names = {
          usage: "Usage:",
          arguments: "Arguments:",
          keywords: "Keywords:",
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
      def help(&block)
        sections = Sections.new

        sections.add(:header, help_header) if @usage.header?
        sections.add(:banner, help_banner)
        sections.add(:description, help_description) if @usage.desc?

        if @parameters.arguments.any?(&:display?)
          sections.add(:arguments, help_arguments)
        end

        if @parameters.keywords.any?(&:display?)
          sections.add(:keywords, help_keywords)
        end

        if @parameters.options?
          sections.add(:options, help_options)
        end

        if @parameters.environments.any?(&:display?)
          sections.add(:environments, help_environments)
        end

        sections.add(:examples, help_examples) if @usage.example?
        sections.add(:footer, help_footer) if @usage.footer?

        if block_given?
          yield(sections)
        end

        formatted = sections.reject(&:empty?).join(NEWLINE)
        formatted.end_with?(NEWLINE) ? formatted : formatted + NEWLINE
      end

      def help_header
        format_multiline(@usage.header, 0) + NEWLINE
      end

      def help_banner
        (@usage.banner? ? @usage.banner : format_usage)
      end

      def help_description
        NEWLINE + format_description
      end

      def help_arguments
        NEWLINE + @section_names[:arguments] +
          NEWLINE + format_section(:arguments)
      end

      def help_keywords
        NEWLINE + @section_names[:keywords] + NEWLINE +
          format_section(:keywords, ->(param) { kwarg_param_display(param) })
      end

      def help_options
        NEWLINE + @section_names[:options] + NEWLINE + format_options
      end

      def help_environments
        NEWLINE + @section_names[:env] + NEWLINE + format_section(:environments)
      end

      def help_examples
        NEWLINE + @section_names[:examples] + NEWLINE + format_examples
      end

      def help_footer
        NEWLINE + format_multiline(@usage.footer, 0)
      end

      private

      # Provide a default usage banner
      #
      # @api private
      def format_usage
        usage = @section_names[:usage] + SPACE
        output = []
        output << @usage.program
        output << " #{@usage.commands.join(" ")}" if @usage.command?
        output << " [#{@param_display.("options")}]" if @parameters.options?
        output << " [#{@param_display.("environment")}]" if @parameters.environments?
        output << " #{format_arguments_usage}" if @parameters.arguments?
        output << " #{format_keywords_usage}" if @parameters.keywords?
        usage + wrap(output.join, indent: usage.length, width: width)
      end

      # Format arguments
      #
      # @api private
      def format_arguments_usage
        return "" unless @parameters.arguments?

        @parameters.arguments.reduce([]) do |acc, arg|
          next acc if arg.hidden?

          acc << format_argument_usage(arg)
        end.join(SPACE)
      end

      # Provide an argument summary
      #
      # @api private
      def format_argument_usage(arg)
        arg_name = @param_display.(arg.variable)
        format_parameter_usage(arg, arg_name)
      end

      # Format parameter usage
      #
      # @api private
      def format_parameter_usage(param, param_name)
        args = []
        if 0 < param.arity
          args << "[" if param.optional?
          args << param_name
          (param.arity - 1).times { args << " #{param_name}" }
          args. << "]" if param.optional?
          args.join
        else
          (param.arity.abs - 1).times { args << param_name }
          args << "[#{param_name}#{ELLIPSIS}]"
          args.join(SPACE)
        end
      end

      # Format keywords usage
      #
      # @api private
      def format_keywords_usage
        return "" unless @parameters.keywords?

        @parameters.keywords.reduce([]) do |acc, kwarg|
          next acc if kwarg.hidden?

          acc << format_keyword_usage(kwarg)
        end.join(SPACE)
      end

      # Provide a keyword summary
      #
      # @api private
      def format_keyword_usage(kwarg)
        param_name = kwarg_param_display(kwarg, @param_display)
        format_parameter_usage(kwarg, param_name)
      end

      # Provide a keyword argument display format
      #
      # @api private
      def kwarg_param_display(kwarg, param_display = NOOP_PROC)
        kwarg_name = param_display.(kwarg.variable)
        conv_name = case kwarg.convert
                    when Proc, NilClass
                      kwarg_name
                    else
                      param_display.(kwarg.convert)
                    end

        "#{kwarg_name}=#{conv_name}"
      end

      # Format a parameter section in the help display
      #
      # @param [String] parameters_name
      #   the name of parameter type
      #
      # @param [Proc] name_selector
      #   selects a name from the parameter, by defeault the variable
      #
      # @return [String]
      #
      # @api private
      def format_section(parameters_name, name_selector = DEFAULT_NAME_SELECTOR)
        params = @parameters.public_send(parameters_name)
        longest_param = params.map(&name_selector).compact.max_by(&:length).length
        ordered_params = @order.(params)

        ordered_params.reduce([]) do |acc, param|
          next acc if param.hidden?

          acc << format_section_parameter(param, longest_param, name_selector)
        end.join(NEWLINE)
      end

      # Format a section parameter line
      #
      # @return [String]
      #
      # @api private
      def format_section_parameter(param, longest_param, name_selector)
        line = []
        desc = []
        indent = @param_indent + longest_param + 2
        param_name = name_selector.(param)

        if param.desc?
          line << format("%s%-#{longest_param}s", " " * @param_indent, param_name)
          desc << "  #{param.desc}"
        else
          line << format("%s%s", " " * @param_indent, param_name)
        end

        if param.permit?
          desc << format(" (permitted: %s)", param.permit.join(", "))
        end

        if (default = format_default(param))
          desc << default
        end

        line << wrap(desc.join, indent: indent, width: width)
        line.join
      end

      # Format multiline description
      #
      # @api private
      def format_description
        format_multiline(@usage.desc, 0)
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
        ordered_options = @order.(@parameters.options)

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
        desc = []
        indent = 0

        if any_short
          short_option = option.short? ? option.short_name : SPACE
          line << format("%#{SHORT_OPT_LENGTH}s", short_option)
          indent += SHORT_OPT_LENGTH
        end

        # short & long option separator
        line << ((option.short? && option.long?) ? ", " : "  ")
        indent += 2

        if option.long?
          if option.desc?
            line << format("%-#{longest_length}s", option.long)
          else
            line << option.long
          end
        else
          line << format("%-#{longest_length}s", SPACE)
        end
        indent += longest_length

        if option.desc?
          desc << "  #{option.desc}"
        end
        indent += 2

        if option.permit?
          desc << format(" (permitted: %s)", option.permit.join(","))
        end

        if (default = format_default(option))
          desc << default
        end

        line << wrap(desc.join, indent: indent, width: width)

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

      # Format examples section
      #
      # @api private
      def format_examples
        format_multiline(@usage.example, @param_indent)
      end

      # Format multiline content
      #
      # @api private
      def format_multiline(lines, indent)
        last_index = lines.size - 1
        lines.map.with_index do |line, i|
          line.map do |part|
            part.split(NEWLINE).map do |p|
              wrap(p, indent: indent, width: width, indent_first: true)
            end.join(NEWLINE)
          end.join(NEWLINE) + (last_index != i ? NEWLINE : "")
        end.join(NEWLINE)
      end
    end # Formatter
  end # Option
end # TTY
