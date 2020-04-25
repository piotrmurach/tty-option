# frozen_string_literal: true

module TTY
  module Option
    class Formatter
      SHORT_OPT_LENGTH = 4
      SHORT_OPT_SPACING = 6
      NEWLINE = "\n"

      # @api public
      def self.help(parameters)
        new(parameters).help
      end

      # @param [Parameters]
      #
      # @api public
      def initialize(parameters)
        @parameters = parameters
      end

      def help
        "Options:\n" + format_options
      end

      private

      # Returns all the options formatted to fit 80 columns
      #
      # @return [String]
      #
      # @api public
      def format_options
        output = []
        longest_option = @parameters.options.map(&:long)
                                    .compact.max_by(&:length).length
        ordered_options = @parameters.options.sort

        ordered_options.each do |option|
          output << format_option(option, longest_option)
        end

        output.join(NEWLINE)
      end

      # Format an option
      #
      # @api private
      def format_option(option, longest_length)
        line = []

        short_option = option.short? ? option.short_name : " "
        line << format("%#{SHORT_OPT_LENGTH}s", short_option)

        # short & long option separator
        line << ((option.short? && option.long?) ? ", " : "  ")

        if option.long?
          if option.desc?
            line << format("%-#{longest_length}s", option.long)
          else
            line << option.long
          end
        else
          line << format("%-#{longest_length}s", " ")
        end

        if option.desc?
          line << "   #{option.desc}"
        end

        if option.default? && ![true, false].include?(option.default)
          if option.default.is_a?(String)
            line << format(" (default %p)", option.default)
          else
            line << format(" (default %s)", option.default)
          end
        end

        line.join
      end
    end # Formatter
  end # Option
end # TTY
