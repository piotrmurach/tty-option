# frozen_string_literal: true

module TTY
  module Option
    class ErrorAggregator
      # Collected errors
      attr_reader :errors

      def initialize(errors = {}, **config)
        @errors = errors
        @raise_on_parsing_error = config.fetch(:raise_on_parsing_error) { true }
      end

      # Record or raise an error
      #
      # @param [TTY::Option::Error] error
      # @param [String] message
      #
      # @api public
      def call(error, message = nil)
        is_class = error.is_a?(Class)

        if @raise_on_parsing_error
          if is_class
            raise error, message
          else
            raise error
          end
        end

        type_name = is_class ? error.name : error.class.name
        type_key = type_name.to_s.split("::").last
                            .gsub(/([a-z]+)([A-Z])/, "\\1_\\2")
                            .downcase.to_sym

        msg = message ? message : error.message

        if error.respond_to?(:param) && error.param
          (@errors[error.param.name] ||= {}).merge!(type_key => msg)
        else
          (@errors[:messages] ||= []) << { type_key => msg }
        end
      end
    end # ErrorAggregator
  end # Option
end # TTY
