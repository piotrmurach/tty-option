# frozen_string_literal: true

require_relative "sections"
require_relative "usage_wrapper"

module TTY
  module Option
    class Formatter
      include UsageWrapper

      BOOLEANS = [true, false].freeze
      DEFAULT_WIDTH = 80
      DOUBLE_SPACE = "  "
      ELLIPSIS = "..."
      EMPTY = ""
      LIST_SEPARATOR = ", "
      MAP_SEPARATOR = ":"
      NEWLINE = "\n"
      SPACE = " "

      DEFAULT_NAME_SELECTOR = ->(param) { param.name }
      DEFAULT_ORDER = ->(params) { params.sort }
      DEFAULT_PARAM_DISPLAY = ->(str) { str.to_s.upcase }
      NOOP_PROC = ->(param) { param }

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
        @space_indent = SPACE * indent
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
      # @yieldparam [TTY::Option::Sections] sections
      #
      # @return [String]
      #
      # @api public
      def help
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

        yield(sections) if block_given?

        formatted = sections.reject(&:empty?).join(NEWLINE)
        formatted.end_with?(NEWLINE) ? formatted : formatted + NEWLINE
      end

      def help_header
        "#{format_multiline(@usage.header, @indent)}#{NEWLINE}"
      end

      def help_banner
        (@usage.banner? ? @usage.banner : format_usage)
      end

      def help_description
        "#{NEWLINE}#{format_description}"
      end

      def help_arguments
        "#{NEWLINE}#{@space_indent}#{@section_names[:arguments]}#{NEWLINE}" +
          format_section(@parameters.arguments, ->(param) do
            @param_display.(param.name)
          end)
      end

      def help_keywords
        "#{NEWLINE}#{@space_indent}#{@section_names[:keywords]}#{NEWLINE}" +
          format_section(@parameters.keywords, ->(param) do
            kwarg_param_display(param).split("=").map(&@param_display).join("=")
          end)
      end

      def help_options
        "#{NEWLINE}#{@space_indent}#{@section_names[:options]}#{NEWLINE}" +
          format_options
      end

      def help_environments
        "#{NEWLINE}#{@space_indent}#{@section_names[:env]}#{NEWLINE}" +
          format_section(@order.(@parameters.environments))
      end

      def help_examples
        "#{NEWLINE}#{@space_indent}#{@section_names[:examples]}#{NEWLINE}" +
          format_examples
      end

      def help_footer
        "#{NEWLINE}#{format_multiline(@usage.footer, @indent)}"
      end

      private

      # Provide a default usage banner
      #
      # @api private
      def format_usage
        usage = @space_indent + @section_names[:usage] + SPACE
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
        arg_name = @param_display.(arg.name)
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
          args << "]" if param.optional?
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
        kwarg_name = param_display.(kwarg.name)
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
      # @param [Array<TTY::Option::Parameter>] params
      #   the parameters to format
      # @param [Proc] name_selector
      #   the parameter name selector, by default, calls the name
      #
      # @return [String]
      #
      # @api private
      def format_section(params, name_selector = DEFAULT_NAME_SELECTOR)
        longest_param = find_longest_parameter(params, &name_selector)

        params.reduce([]) do |acc, param|
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
          line << format("%s%-#{longest_param}s", SPACE * @param_indent, param_name)
          desc << "  #{param.desc}"
        else
          line << format("%s%s", SPACE * @param_indent, param_name)
        end

        if param.permit?
          desc << format_permitted(param.permit)
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
        format_multiline(@usage.desc, @indent)
      end

      # Returns all the options formatted to fit 80 columns
      #
      # @return [String]
      #
      # @api private
      def format_options
        return "" if @parameters.options.empty?

        ordered_options = @order.(@parameters.options)
        longest_short = find_longest_short_option
        longest_long = find_longest_long_option

        ordered_options.reduce([]) do |acc, option|
          next acc if option.hidden?

          acc << format_option(option, longest_short, longest_long)
        end.join(NEWLINE)
      end

      # Find the longest short option
      #
      # @return [Integer, nil]
      #
      # @api private
      def find_longest_short_option
        find_longest_parameter(@parameters.options, &:short)
      end

      # Find the longest long option
      #
      # @return [Integer, nil]
      #
      # @api private
      def find_longest_long_option
        find_longest_parameter(@parameters.options, &:long)
      end

      # Find the longest parameter
      #
      # @param [Array<TTY::Option::Parameter>] params
      #   the parameters to search
      #
      # @yield [TTY::Option::Parameter]
      #
      # @return [Integer, nil]
      #
      # @api private
      def find_longest_parameter(params, &name_selector)
        params = params.reject(&:hidden?).map(&name_selector).compact

        params.max_by(&:length).length if params.any?
      end

      # Format an option
      #
      # @param [TTY::Option::Parameter::Option] option
      #   the option to format
      # @param [Integer, nil] longest_short
      #   the longest short option length or nil
      # @param [Integer, nil] longest_long
      #   the longest long option length or nil
      #
      # @return [String]
      #
      # @api private
      def format_option(option, longest_short, longest_long)
        line = [@space_indent]
        indent = @indent

        if longest_short
          line << "  #{format_short_option(option, longest_short)}"
          indent += line.last.length
        end

        if longest_long
          separator = short_and_long_option_separator(option)
          line << "#{separator}#{format_long_option(option, longest_long)}"
          indent += line.last.length
        end

        if parameter_description?(option)
          indent += 2
          desc = format_parameter_description(option)
          line << wrap(desc, indent: indent, width: width)
        end

        line.join
      end

      # Format a short option
      #
      # @param [TTY::Option::Parameter::Option] option
      #   the option to format
      # @param [Integer] longest
      #   the longest short option length
      #
      # @return [String]
      #
      # @api private
      def format_short_option(option, longest)
        if option.long?
          format("%-#{longest}s", option.short_name)
        elsif parameter_description?(option)
          format("%-#{longest}s", option.short)
        else
          option.short
        end
      end

      # Format a long option
      #
      # @param [TTY::Option::Parameter::Option] option
      #   the option to format
      # @param [Integer] longest
      #   the longest long option length
      #
      # @return [String]
      #
      # @api private
      def format_long_option(option, longest)
        if option.long?
          if parameter_description?(option)
            format("%-#{longest}s", option.long)
          else
            option.long
          end
        elsif parameter_description?(option)
          format("%-#{longest}s", SPACE)
        end
      end

      # Short and long option separator
      #
      # @param [TTY::Option::Parameter::Option] option
      #   the option to separate short and long names
      #
      # @return [String]
      #
      # @api private
      def short_and_long_option_separator(option)
        if option.short? && option.long?
          LIST_SEPARATOR
        elsif option.long? || parameter_description?(option)
          DOUBLE_SPACE
        else
          EMPTY
        end
      end

      # Format a parameter description
      #
      # @param [TTY::Option::Parameter] param
      #   the parameter to format
      #
      # @return [String]
      #
      # @api private
      def format_parameter_description(param)
        desc = []

        desc << "  #{param.desc}" if param.desc?

        if param.permit?
          desc << SPACE unless param.desc?
          desc << format_permitted(param.permit)
        end

        if (default = format_default(param))
          desc << SPACE unless param.desc?
          desc << default
        end

        desc.join
      end

      # Check whether or not parameter has description
      #
      # @param [TTY::Option::Parameter] param
      #   the parameter to check for description
      #
      # @return [Boolean]
      #
      # @api private
      def parameter_description?(param)
        param.desc? || param.permit? || parameter_default?(param)
      end

      # Check whether or not parameter has default
      #
      # @param [TTY::Option::Parameter] param
      #   the parameter to check for default
      #
      # @return [Boolean]
      #
      # @api private
      def parameter_default?(param)
        param.default? && !BOOLEANS.include?(param.default)
      end

      # Format permitted values
      #
      # @param [Parameter] values
      #   the permitted values to format
      #
      # @return [String]
      #
      # @api private
      def format_permitted(values)
        format(" (permitted: %s)", values.map do |val|
          val.respond_to?(:to_ary) ? val.join(MAP_SEPARATOR) : val
        end.join(LIST_SEPARATOR))
      end

      # Format a default value
      #
      # @param [TTY::Option::Parameter] param
      #   the parameter to format
      #
      # @return [String]
      #
      # @api private
      def format_default(param)
        return unless parameter_default?(param)

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
          end.join(NEWLINE) + (last_index == i ? EMPTY : NEWLINE)
        end.join(NEWLINE)
      end
    end # Formatter
  end # Option
end # TTY
