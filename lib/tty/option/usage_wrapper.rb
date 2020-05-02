# frozen_string_literal: true

module TTY
  module Option
    module UsageWrapper
      # Wrap a string to a maximum width with indentation
      #
      # @param [String] text
      # @param [Integer] width
      # @param [Integer] indent
      #
      # @api public
      def self.wrap(text, width: 80, indent: 2)
        wrap = width - indent
        lines = []

        line, rest = *next_line(text, wrap: wrap)
        lines << line # don't indent the first line

        while !rest.nil?
          line, rest = *next_line(rest, wrap: wrap)
          lines << " " * indent + line.strip
        end

        lines.join("\n")
      end

      # Extract a line from a string and return remainder
      #
      # @param [String] str
      # @param [Integer] wrap
      #
      # @return [Array<String, String>]
      #
      # @api private
      def self.next_line(text, wrap: nil)
        line = text[0, wrap + 1] # account for word boundary
        index = line.index("\n", 1)

        # line without newlines and can be broken
        if (index.nil? || index.zero?) && wrap < line.length
          index = line.rindex(/\s/)
        end

        # line without any whitespace
        if index.nil? || index.zero?
          index = wrap
        end

        [text[0...index], text[index..-1]]
      end
      private_class_method :next_line
    end # StringsHelper
  end # Option
end # TTY
