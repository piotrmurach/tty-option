# frozen_string_literal: true

module TTY
  module Option
    class Parser
      module ParamTypes
        # Check if value looks like an argument
        #
        # @param [String] value
        #
        # @return [Boolean]
        #
        # @api public
        def argument?(value)
          !value.match(/^[^-][^=]*\z/).nil?
        end

        # Check if value is an environment variable
        #
        # @param [String] value
        #
        # @return [Boolean]
        #
        # @api public
        def env_var?(value)
          !value.match(/^[\p{Lu}_\-\d]+=/).nil?
        end

        # Check to see if value is a keyword
        #
        # @return [Boolean]
        #
        # @api public
        def keyword?(value)
          !value.to_s.match(/^([^-=][\p{Ll}_\-\d]*)=([^=]+)/).nil?
        end

        # Check if value looks like an option
        #
        # @param [String] value
        #
        # @return [Boolean]
        #
        # @api public
        def option?(value)
          !value.match(/^-./).nil?
        end
      end # ParamTypes
    end # Parser
  end # Option
end # TTY
