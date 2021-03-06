# frozen_string_literal: true

require_relative "const"
require_relative "converter"

module TTY
  module Option
    module Conversions
      extend Converter

      TRUE_VALUES = /^(true|y(es)?|t|1)$/i.freeze
      FALSE_VALUES = /^(false|n(o)?|f|0)$/i.freeze

      convert :bool, :boolean do |val|
        case val.to_s
        when TRUE_VALUES
          true
        when FALSE_VALUES
          false
        else
          Const::Undefined
        end
      end

      convert :date do |val|
        begin
          require "date" unless defined?(::Date)
          ::Date.parse(val)
        rescue ArgumentError, TypeError
          Const::Undefined
        end
      end

      convert :float do |val|
        begin
          Float(val)
        rescue ArgumentError, TypeError
          Const::Undefined
        end
      end

      convert :int, :integer do |val|
        begin
          Float(val).to_i
        rescue ArgumentError, TypeError
          Const::Undefined
        end
      end

      convert :pathname, :path do |val|
        require "pathname"
        ::Pathname.new(val.to_s)
      end

      convert :regexp do |val|
        begin
          Regexp.new(val.to_s)
        rescue TypeError, RegexpError
          Const::Undefined
        end
      end

      convert :sym, :symbol do |val|
        begin
          String(val).to_sym
        rescue ArgumentError
          Const::Undefined
        end
      end

      convert :uri do |val|
        begin
          require "uri"
          ::URI.parse(val)
        rescue ::URI::InvalidURIError
          Const::Undefined
        end
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

      conversions.keys.each do |type|
        next if type =~ /list|array|map|hash/

        [:"#{type}_list", :"#{type}_array", :"#{type}s"].each do |new_type|
          convert new_type do |val|
            conversions[:list].(val).map do |obj|
              conversions[type].(obj)
            end
          end
        end

        [:"#{type}_map", :"#{type}_hash"].each do |new_type|
          convert new_type do |val|
            conversions[:map].(val).each_with_object({}) do |(k, v), h|
              h[k] = conversions[type].(v)
            end
          end
        end
      end
    end # Conversions
  end # Option
end # TTY
