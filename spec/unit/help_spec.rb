# frozen_string_literal: true

RSpec.describe TTY::Option::Formatter do
  def command(&block)
    stub_const("Command", Class.new)
    Command.send :include, TTY::Option
    Command.class_eval(&block)
    Command
  end

  def new_command(&block)
    command(&block).new
  end

  context "Usage banner" do
    it "formats banner with a single argument, description and no options" do
      cmd = new_command do
        argument :foo do
          required
        end

        desc "Some description"
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec FOO

      Some description
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats banner with no arguments and some options" do
      cmd = new_command do
        option :foo do
          desc "Some description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec [OPTIONS]

      Options:
            --foo   Some description
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats banner with required & optional arguments and options" do
      cmd = new_command do
        argument :foo do
          required
          arity 2
        end

        argument :bar do
          optional
        end

        option :baz do
          desc "Some description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec [OPTIONS] FOO FOO [BAR]

      Options:
            --baz   Some description
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats banner with any arguments and options" do
      cmd = new_command do
        program "foo"

        argument :bar do
          arity zero_or_more
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: foo [BAR...]
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats banner with one or more arguments and no options" do
      cmd = new_command do
        program "foo"

        argument :bar do
          arity one_or_more
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: foo BAR [BAR...]
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "uses a custom banner" do
      cmd = new_command do
        banner "Usage: #{program} BAR BAZ"
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec BAR BAZ
      EOS

      expect(cmd.help).to eq(expected_output)
    end
  end

  context "Options section" do
    it "prints help information for options" do
      cmd = new_command do
        option :foo do
          short "-f"
          long "--foo string"
          desc "Some description"
        end

        option :bar do
          short "-b"
          long "--bar string"
          default "baz"
          desc "Some description"
        end

        option :qux do
          long "--qux-long ints"
          desc "Some description"
          default [1,2,3]
        end

        flag :fum do
          long "--fum"
          desc "Some description"
        end

        flag :baz

        flag :corge do
          short "-c"
          desc "Some description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec [OPTIONS]

      Options:
        -b, --bar string      Some description (default "baz")
            --baz
        -f, --foo string      Some description
            --fum             Some description
            --qux-long ints   Some description (default [1, 2, 3])
        -c                    Some description
      EOS

      expect(cmd.help).to eq(expected_output)
    end
  end

  context "Environment section" do
    it "displays environment variables in help when present" do
      cmd = new_command do
        option :foo do
          short "-f"
          long "--foo string"
          desc "Some description"
        end

        env :bar do
          var "BARRRRR_VAR"
          default "some"
          desc "Some description"
        end

        env :baz do
          var "BAZ_VAR"
          desc "Some description"
        end

        env :qux_var do
          var "A_VAR"
          desc "Some description"
        end

        env :fum do
          var "FUM_VAR"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec [OPTIONS] [ENVIRONMENT]

      Options:
        -f, --foo string   Some description

      Environment:
        A_VAR         Some description
        BARRRRR_VAR   Some description (default "some")
        BAZ_VAR       Some description
        FUM_VAR
      EOS

      expect(cmd.help).to eq(expected_output)
    end
  end
end
