# frozen_string_literal: true

module TTY
  module Option
    class Parameter
      class Environment < Parameter
        def default_variable_name
          name.to_s.tr("-", "_").upcase
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
