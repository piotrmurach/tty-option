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

  context "Usage header & footer" do
    it "includes header and footer in help display" do
      cmd = new_command do
        header "CLI app"

        footer "Run --help to see more info."
      end

      expected_output = unindent(<<-EOS)
      CLI app

      Usage: rspec

      Run --help to see more info.
      EOS

      expect(cmd.help).to eq(expected_output)
    end
  end

  context "Usage banner" do
    it "formats banner with a single argument, description and no options" do
      func = method(:unindent)
      cmd = new_command do
        argument :foo do
          required
        end

        argument :bar do
          hidden
        end

        desc "Some description", "on multiline"

        desc func.(<<-EOS)
        Another description
        on multiline
        EOS
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec FOO

      Some description
      on multiline

      Another description
      on multiline
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats banner with no arguments and some options" do
      cmd = new_command do
        desc "Main description"

        option :foo do
          desc "Some description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec [OPTIONS]

      Main description

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
          desc "Foo arg description"
          permit [10, 11, 12]
        end

        argument :bar do
          optional
          desc "Bar arg description"
          default "fum"
        end

        option :baz do
          desc "Some description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec [OPTIONS] FOO FOO [BAR]

      Arguments:
        bar  Bar arg description (default "fum")
        foo  Foo arg description (permitted: 10,11,12)

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

    it "formats banner with custom argument names" do
      cmd = new_command do
        argument :foo do
          variable "foo-bar"
          required
          arity 2
          desc "Foo arg description"
        end

        argument :bar do
          variable "barred"
          optional
          desc "Bar arg description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec FOO-BAR FOO-BAR [BARRED]

      Arguments:
        barred   Bar arg description
        foo-bar  Foo arg description
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

    it "formats banner with keyword arguments and no arguments or options" do
      cmd = new_command do
        program "foo"

        keyword :bar do
          required
          convert :uri
          desc "Bar keyword description"
        end

        keyword :baz do
          default "fum"
          desc "Baz keyword description"
        end

        keyword :qux do
          hidden
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: foo BAR=URI [BAZ=BAZ]

      Keywords:
        bar  Bar keyword description
        baz  Baz keyword description (default "fum")
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats banner with custom keyword names" do
      cmd = new_command do
        program "foo"

        keyword :foo do
          variable "foo-bar"
          required
          arity 2
          desc "Some keyword description"
          convert :int
        end

        keyword :bar do
          variable "barred"
          optional
          arity 2
          desc "Some keyword description"
        end

        keyword :baz do
          variable "bazzed"
          arity one_or_more
          desc "Some keyword description"
          convert :list
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: foo FOO-BAR=INT FOO-BAR=INT [BARRED=BARRED BARRED=BARRED] BAZZED=LIST [BAZZED=LIST...]

      Keywords:
        barred   Some keyword description
        bazzed   Some keyword description
        foo-bar  Some keyword description
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats banner with keyword and positional arguments and options" do
      cmd = new_command do
        program "foo"

        keyword :bar do
          required
          convert :uri
        end

        keyword :baz

        argument :fum do
          required
        end

        option :qux do
          desc "Some description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: foo [OPTIONS] FUM BAR=URI [BAZ=BAZ]

      Options:
        --qux   Some description
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "changes banner parameters display with :param_display configuration" do
      cmd = new_command do
        program "foo"

        keyword :bar do
          required
          convert :uri
        end

        keyword :baz

        argument :fum do
          required
        end

        option :qux do
          desc "Some description"
        end

        env :quux do
          desc "Some description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: foo [<options>] [<environment>] <fum> <bar>=<uri> [<baz>=<baz>]

      Options:
        --qux   Some description

      Environment:
        QUUX  Some description
      EOS

      param_display = ->(str) { "<#{str.downcase}>"}

      expect(cmd.help(param_display: param_display)).to eq(expected_output)
    end
  end

  context "Options section" do
    it "prints help information for options" do
      cmd = new_command do
        option :foo do
          short "-f"
          long "--foo string"
          permit %w[a b c d]
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

        option :quux do
          hidden
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
        -f, --foo string      Some description (permitted: a,b,c,d)
            --fum             Some description
            --qux-long ints   Some description (default [1, 2, 3])
        -c                    Some description
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "prints help information for only long options" do
      cmd = new_command do
        option :foo do
          long "--foo string"
          desc "Some description"
        end

        option :bar do
          long "--bar string"
          default "baz"
          desc "Some description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec [OPTIONS]

      Options:
        --bar string   Some description (default "baz")
        --foo string   Some description
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
          permit %w[a b c]
        end

        env :qux_var do
          var "A_VAR"
          desc "Some description"
        end

        env :fum do
          var "FUM_VAR"
        end

        env :quuz do
          hidden
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec [OPTIONS] [ENVIRONMENT]

      Options:
        -f, --foo string   Some description

      Environment:
        A_VAR        Some description
        BARRRRR_VAR  Some description (default "some")
        BAZ_VAR      Some description (permitted: a,b,c)
        FUM_VAR
      EOS

      expect(cmd.help).to eq(expected_output)
    end
  end

  context "Examples section" do
    it "displays examples in help when present" do
      func = method(:unindent)
      cmd = new_command do
        program "foo"

        example "The following does something:", "  $ foo bar"

        example func.(<<-EOS)
        The following does something as well:
          $ foo baz
        EOS
      end

      expected_output = unindent(<<-EOS)
      Usage: foo

      Examples:
        The following does something:
          $ foo bar

        The following does something as well:
          $ foo baz
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "displays examples in help with other sections" do
      cmd = new_command do
        program "foo"

        option :bar do
          desc "Some description"
        end

        env :baz do
          desc "Some description"
        end

        example "The following does something:", "  $ foo bar"

        footer "Version 1.2.3"
      end

      expected_output = unindent(<<-EOS)
      Usage: foo [OPTIONS] [ENVIRONMENT]

      Options:
        --bar   Some description

      Environment:
        BAZ  Some description

      Examples:
        The following does something:
          $ foo bar

      Version 1.2.3
      EOS

      expect(cmd.help).to eq(expected_output)
    end
  end

  context "full usage info" do
    it "displays usage info using properties" do
      cmd = new_command do
        usage program: "foo",
              header: "CLI foo app",
              description: "Some foo app description",
              example: ["Some example", "on multiline"],
              footer: "Run --help to see more info."

        argument :bar do
          required
          desc "Some argument description"
        end

        keyword :baz do
          desc "Some keyword description"
        end

        flag :qux do
          desc "Some option description"
        end

        env :fum do
          desc "Some env description"
        end
      end

      expected_output = unindent(<<-EOS)
      CLI foo app

      Usage: foo [OPTIONS] [ENVIRONMENT] BAR [BAZ=BAZ]

      Some foo app description

      Arguments:
        bar  Some argument description

      Keywords:
        baz  Some keyword description

      Options:
        --qux   Some option description

      Environment:
        FUM  Some env description

      Examples:
        Some example
        on multiline

      Run --help to see more info.
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "changes default alphabetical ordering to definition" do
      cmd = new_command do
        program "foo"

        argument :z, desc: "Some argument description"
        argument :d, desc: "Some argument description"
        argument :f, desc: "Some argument description"

        keyword :zz, desc: "Some keyword description"
        keyword :dd, desc: "Some keyword description"
        keyword :ff, desc: "Some keyword description"

        option :zzz
        option :ddd
        option :fff

        env :zzzz, desc: "Some env description"
        env :dddd, desc: "Some env description"
        env :ffff, desc: "Some env description"
      end

      expected_output = unindent(<<-EOS)
      Usage: foo [OPTIONS] [ENVIRONMENT] [Z] [D] [F] [ZZ=ZZ] [DD=DD] [FF=FF]

      Arguments:
        z  Some argument description
        d  Some argument description
        f  Some argument description

      Keywords:
        zz  Some keyword description
        dd  Some keyword description
        ff  Some keyword description

      Options:
        --zzz
        --ddd
        --fff

      Environment:
        ZZZZ  Some env description
        DDDD  Some env description
        FFFF  Some env description
      EOS

      expect(cmd.help(order: ->(params) { params })).to eq(expected_output)
    end
  end
end
