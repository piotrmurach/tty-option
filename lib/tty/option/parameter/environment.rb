# frozen_string_literal: true

module TTY
  module Option
    class Parameter
      class Environment < Parameter
        def required?
          @settings.fetch(:required) { false }
        end

        def variable(value = (not_set = true))
          if not_set
            @settings[:variable] || @settings[:var] || default_variable_name
          else
            @settings[:variable] = value
            @settings[:var] = value
          end
        end
        alias var variable

        def default_variable_name
          name.to_s.gsub(/-/, "_").upcase
        end

        # Compare this env var to another
        #
        # @api public
        def <=>(other)
          variable <=> other.variable
        end
      end
    end # Parameter
  end # Option
end # TTY
