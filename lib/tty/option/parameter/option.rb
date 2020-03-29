# frozen_string_literal: true

module TTY
  module Option
    class Parameter
      class Option < Parameter
        def short(value = (not_set = true))
          if not_set
            @settings[:short]
          else
            @settings[:short] = value
          end
        end

        def short?
          @settings.key?(:short) && !@settings[:short].nil?
        end

        # Extract short flag name
        #
        # @api public
        def short_name
          short.to_s.sub(/^(-.).*$/, "\\1")
        end

        def long(value = (not_set = true))
          if not_set
            @settings.fetch(:long) { default_long }
          else
            @settings[:long] = value
          end
        end

        def default_long
          "--#{name.to_s.gsub("_", "-")}" unless short?
        end

        def long?
          !long.nil?
        end

        # Extract long flag name
        #
        # @api public
        def long_name
          long.to_s.sub(/^(--.+?)(\s+|\=|\[).*$/, "\\1")
        end

        def required?
          @settings.fetch(:required) { false }
        end
      end # Option
    end # Parameter
  end # Option
end # TTY
