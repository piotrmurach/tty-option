# frozen_string_literal: true

require_relative "converter"

module TTY
  module Option
    module Conversions
      extend Converter

      TRUE_VALUES = /^(true|y(es)?|t|1)$/i.freeze
      FALSE_VALUES = /^(false|n(o)?|f|0)$/i.freeze

      # @api public
      def self.raise_invalid_argument(conv_name, val)
        raise InvalidConversionArgument,
              format("Invalid value of %s for %s conversion",
                     val.inspect, conv_name.inspect)
      end

      convert :bool, :boolean do |val|
        case val.to_s
        when TRUE_VALUES
          true
        when FALSE_VALUES
          false
        else
          raise_invalid_argument(:bool, val)
        end
      end

      convert :date do |val|
        require "date" unless defined?(::Date)
        ::Date.parse(val)
      rescue ArgumentError
        raise_invalid_argument(:date, val)
      end

      convert :float do |val|
        Float(val)
      rescue ArgumentError
        raise_invalid_argument(:float, val)
      end

      convert :int, :integer do |val|
        Float(val).to_i
      rescue ArgumentError
        raise_invalid_argument(:int, val)
      end

      convert :pathname, :path do |val|
        require "pathname"
        ::Pathname.new(val.to_s)
      end

      convert :regexp do |val|
        Regexp.new(val.to_s)
      rescue TypeError, RegexpError
        raise_invalid_argument(:regexp, val)
      end

      convert :sym, :symbol do |val|
        String(val).to_sym
      rescue ArgumentError
        raise_invalid_argument(:symbol, val)
      end

      convert :uri do |val|
        require "uri"
        ::URI.parse(val)
      rescue ::URI::InvalidURIError
        raise_invalid_argument(:uri, val)
      end

      convert :list, :array do |val|
        (val.respond_to?(:to_a) ? val : val.split(/(?<!\\),/))
          .map { |v| v.strip.gsub(/\\,/, ",") }
          .reject(&:empty?)
      end

      convert :map, :hash do |val|
        values = val.respond_to?(:to_a) ? val : val.split(/[& ]/)
        values.each_with_object({}) do |pair, pairs|
          key, value = pair.split(/[=:]/, 2)
          if (current = pairs[key.to_sym])
            pairs[key.to_sym] = Array(current) << value
          else
            pairs[key.to_sym] = value
          end
          pairs
        end
      end
    end # Conversions
  end # Option
end # TTY
