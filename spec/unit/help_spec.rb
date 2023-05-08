# frozen_string_literal: true

RSpec.describe TTY::Option::Formatter do
  context "Usage header & footer" do
    it "includes header and footer in help display" do
      cmd = new_command do
        header "CLI app"

        footer "Run --help to see more info."
      end

      expected_output = unindent(<<-EOS)
      CLI app

      Usage: rspec command

      Run --help to see more info.
      EOS

      expect(cmd.help).to eq(expected_output)
    end
  end

  context "Usage banner" do
    it "formats banner with a single argument, description and no options" do
      func = method(:unindent)
      cmd = new_command do
        argument :foo

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
      Usage: rspec command FOO

      Some description
      on multiline

      Another description
      on multiline
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "wraps banner description" do
      cmd = new_command do
        usage do
          program "text"

          command "wrap"
        end

        desc "Some long description that explains all the details",
             "of how to use the tool and it goes on and on",
             "and doesn't seem to end at all."

        desc "Another regular line"
      end

      expected_output = unindent(<<-EOS)
      Usage: text wrap

      Some long description that
      explains all the details
      of how to use the tool and it
      goes on and on
      and doesn't seem to end at
      all.

      Another regular line
      EOS

      expect(cmd.help(width: 30)).to eq(expected_output)
    end

    it "formats banner with no arguments and some options" do
      cmd = new_command do
        no_command

        desc "Main description"

        option :foo do
          desc "Some description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec [OPTIONS]

      Main description

      Options:
        --foo  Some description
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats banner with required & optional arguments and options" do
      cmd = new_command do
        argument :foo do
          arity 2
          desc "Foo arg description"
          permit [10, 11, 12]
        end

        argument :bar do
          optional
          desc "Bar arg description"
          default "fum"
        end

        argument :quux do
          hidden
        end

        option :baz do
          desc "Some description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec command [OPTIONS] FOO FOO [BAR]

      Arguments:
        FOO  Foo arg description (permitted: 10, 11, 12)
        BAR  Bar arg description (default "fum")

      Options:
        --baz  Some description
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "wraps long arguments and descriptions to fit the width" do
      cmd = new_command do
        argument :foo do
          name "foo-long-argument-name"
          arity 2
          desc "Some multiline\n description with newlines"
        end

        argument :bar do
          optional
          name "bar-super-long-argument-name"
          default "default-is-way-too-long-as-well"
          desc "Some description that goes on and on and never finishes explaining"
        end

        argument :qux do
          optional
          name "qux-long-name"
          desc "Some description that\nbreaks into multiline\n on newlines"
          default "some long default on many lines"
          permit %w[one two three four five six]
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec command FOO-LONG-ARGUMENT-NAME FOO-LONG-ARGUMENT-NAME
             [BAR-SUPER-LONG-ARGUMENT-NAME] [QUX-LONG-NAME]

      Arguments:
        FOO-LONG-ARGUMENT-NAME        Some multiline
                                      description with newlines
        BAR-SUPER-LONG-ARGUMENT-NAME  Some description that goes on and on and
                                      never finishes explaining (default
                                      "default-is-way-too-long-as-well")
        QUX-LONG-NAME                 Some description that
                                      breaks into multiline
                                      on newlines (permitted: one, two, three,
                                      four, five, six) (default "some long
                                      default on many lines")
      EOS

      expect(cmd.help(width: 75)).to eq(expected_output)
    end

    it "formats permitted hash of values for all parameters" do
      cmd = new_command do
        program "permitted"

        no_command

        argument :foo do
          arity one_or_more
          convert :map
          desc "Foo argument desc"
          permit({a: 1, b: 2, c: 3})
        end

        option :bar do
          convert :map
          desc "Bar option desc"
          permit({d: 4, e: 5, f: 6})
        end

        keyword :baz do
          convert :map
          desc "Baz keyword desc"
          permit({g: 7, h: 8, i: 9})
        end

        env :qux do
          convert :map
          desc "Qux env desc"
          permit({j: 10, k: 11, l: 12})
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: permitted [OPTIONS] [ENVIRONMENT] FOO [FOO...] [BAZ=MAP]

      Arguments:
        FOO  Foo argument desc (permitted: a:1, b:2, c:3)

      Keywords:
        BAZ=MAP  Baz keyword desc (permitted: g:7, h:8, i:9)

      Options:
        --bar  Bar option desc (permitted: d:4, e:5, f:6)

      Environment:
        QUX  Qux env desc (permitted: j:10, k:11, l:12)
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats banner with arguments but no command" do
      cmd = new_command do
        usage do
          program "foo"

          no_command
        end

        argument :bar
        argument :baz
      end

      expected_output = unindent(<<-EOS)
      Usage: foo BAR BAZ
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
      Usage: foo command [BAR...]
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
      Usage: foo command BAR [BAR...]
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats banner with custom argument names" do
      cmd = new_command do
        argument :foo do
          name "foo-bar"
          arity 2
          desc "Foo arg description"
        end

        argument :bar do
          name "barred"
          optional
          desc "Bar arg description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec command FOO-BAR FOO-BAR [BARRED]

      Arguments:
        FOO-BAR  Foo arg description
        BARRED   Bar arg description
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

        keyword :quux do
          hidden
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: foo command BAR=URI [BAZ=BAZ]

      Keywords:
        BAR=URI  Bar keyword description
        BAZ=BAZ  Baz keyword description (default "fum")
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats banner with custom keyword names" do
      cmd = new_command do
        program "foo"

        keyword :foo do
          name "foo-bar"
          required
          arity 2
          desc "Some keyword description"
          convert :int
        end

        keyword :bar do
          name "barred"
          optional
          arity 2
          desc "Some keyword description"
        end

        keyword :baz do
          name "bazzed"
          arity one_or_more
          desc "Some keyword description"
          convert :list
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: foo command FOO-BAR=INT FOO-BAR=INT [BARRED=BARRED BARRED=BARRED]
             BAZZED=LIST [BAZZED=LIST...]

      Keywords:
        FOO-BAR=INT    Some keyword description
        BARRED=BARRED  Some keyword description
        BAZZED=LIST    Some keyword description
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "wraps long keyword arguments and descriptions to fit the width" do
      cmd = new_command do
        keyword :foo do
          required
          name "foo-long-name"
          convert :float
          arity 2
          desc "Some multiline\n description with newlines"
        end

        keyword :bar do
          optional
          name "bar-super-long-keyword-name"
          convert :list
          default "default-is-way-too-long-as-well"
          desc "Some description that goes on and on and never finishes explaining"
        end

        keyword :qux do
          name "qux-long-name"
          convert :int
          desc "Some description that\nbreaks into multiline\n on newlines"
          default "some long default on many lines"
          permit %w[one two three four five six]
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec command FOO-LONG-NAME=FLOAT FOO-LONG-NAME=FLOAT
             [BAR-SUPER-LONG-KEYWORD-NAME=LIST] [QUX-LONG-NAME=INT]

      Keywords:
        FOO-LONG-NAME=FLOAT               Some multiline
                                          description with newlines
        BAR-SUPER-LONG-KEYWORD-NAME=LIST  Some description that goes on and on and
                                          never finishes explaining (default
                                          "default-is-way-too-long-as-well")
        QUX-LONG-NAME=INT                 Some description that
                                          breaks into multiline
                                          on newlines (permitted: one, two, three,
                                          four, five, six) (default "some long
                                          default on many lines")
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

        argument :fum

        option :qux do
          desc "Some description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: foo command [OPTIONS] FUM BAR=URI [BAZ=BAZ]

      Options:
        --qux  Some description
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "changes banner parameters display with :param_display configuration" do
      cmd = new_command do
        program "foo"

        argument :fum do
          desc "Foo arg description"
        end

        keyword :bar do
          required
          convert :uri
        end

        keyword :baz do
          desc "Baz keyword description"
        end

        option :qux do
          desc "Some description"
        end

        env :quux do
          desc "Some description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: foo command [<options>] [<environment>] <fum> <bar>=<uri> [<baz>=<baz>]

      Arguments:
        <fum>  Foo arg description

      Keywords:
        <bar>=<uri>
        <baz>=<baz>  Baz keyword description

      Options:
        --qux  Some description

      Environment:
        QUUX  Some description
      EOS

      param_display = ->(str) { "<#{str.downcase}>" }

      expect(cmd.help(param_display: param_display)).to eq(expected_output)
    end
  end

  context "Options section" do
    it "formats only short options" do
      cmd = new_command do
        option :foo do
          short "-f"
          desc "Foo description"
        end

        option :bar do
          short "-b"
          default 11
        end

        option :baz do
          short "-z"
          permit %w[a b c d]
        end

        option :qux do
          short "-x"
        end

        flag :quux do
          short "-u"
        end

        option :fum do
          short "-mm"
          hidden
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec command [OPTIONS]

      Options:
        -b  (default 11)
        -f  Foo description
        -u
        -x
        -z  (permitted: a, b, c, d)
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats only short options with arguments" do
      cmd = new_command do
        option :foo do
          short "-f sym"
          desc "Foo description"
        end

        option :bar do
          short "-b int"
          default 11
        end

        option :baz do
          short "-z list"
          permit %w[a b c d]
        end

        option :qux do
          short "-x string"
        end

        flag :quux do
          short "-u"
        end

        option :fum do
          short "-m pathname"
          hidden
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec command [OPTIONS]

      Options:
        -b int     (default 11)
        -f sym     Foo description
        -u
        -x string
        -z list    (permitted: a, b, c, d)
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats only long options" do
      cmd = new_command do
        option :foo do
          desc "Foo description"
        end

        option :bar do
          default 11
        end

        option :baz do
          permit %w[a b c d]
        end

        option :qux

        flag :quux

        option :fum do
          long "--fuuuuuum"
          hidden
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec command [OPTIONS]

      Options:
        --bar   (default 11)
        --baz   (permitted: a, b, c, d)
        --foo   Foo description
        --quux
        --qux
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats only long options with arguments" do
      cmd = new_command do
        option :foo do
          long "--foo sym"
          desc "Foo description"
        end

        option :bar do
          long "--bar int"
          default 11
        end

        option :baz do
          long "--baz list"
          permit %w[a b c d]
        end

        option :qux do
          long "--qux string"
        end

        flag :quux do
          long "--quux"
        end

        option :fum do
          long "--fum pathname"
          hidden
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec command [OPTIONS]

      Options:
        --bar int     (default 11)
        --baz list    (permitted: a, b, c, d)
        --foo sym     Foo description
        --quux
        --qux string
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats short and long options with arguments" do
      cmd = new_command do
        option :foo do
          short "-f"
          long "--foo"
          desc "Foo description"
        end

        option :bar do
          short "-b int"
          default 11
        end

        option :baz do
          long "--baz list"
          permit %w[a b c d]
        end

        option :qux do
          short "-q"
          long "--qux string"
        end

        option :quux do
          long "--quux"
        end

        flag :fum do
          short "-u"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec command [OPTIONS]

      Options:
                --baz list    (permitted: a, b, c, d)
        -f    , --foo         Foo description
                --quux
        -q    , --qux string
        -b int                (default 11)
        -u
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "formats options with various settings" do
      cmd = new_command do
        option :foo do
          short "-f"
          long "--foo string"
          permit %w[a b c d]
          desc "Foo description"
        end

        option :bar do
          short "-b"
          long "--bar sym"
          default "baz"
          desc "Bar description"
        end

        option :qux do
          long "--qux-long ints"
          desc "Qux description"
          default [1, 2, 3]
        end

        option :quux do
          hidden
        end

        flag :fum do
          long "--fum"
          desc "Fum description"
        end

        flag :baz

        flag :corge do
          short "-c"
          desc "Corge description"
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec command [OPTIONS]

      Options:
        -b, --bar sym        Bar description (default "baz")
            --baz
        -f, --foo string     Foo description (permitted: a, b, c, d)
            --fum            Fum description
            --qux-long ints  Qux description (default [1, 2, 3])
        -c                   Corge description
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "wraps long options and descriptions to fit the line" do
      cmd = new_command do
        option :foo do
          short "-f"
          long "--foo-long-option-name string"
          desc "Some multiline\n description with newlines"
        end

        option :bar do
          short "-b"
          long "--bar-super-long-option-name string"
          default "default-is-way-too-long-as-well"
          desc "Some description that goes on and on and never finishes explaining"
        end

        option :baz do
          long "--baz string"
          default "default is a long string that splits into multiple lines"
        end

        option :qux do
          short "-q"
          long "--qux-long-name string"
          desc "Some description that\nbreaks into multiline\n on newlines"
          default "some long default on many lines"
          permit %w[one two three four five six]
        end

        option :quux do
          long "--quux string"
          permit %w[one two three four five six seven eight nine]
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec command [OPTIONS]

      Options:
        -b, --bar-super-long-option-name string  Some description that goes on and
                                                 on and never finishes explaining
                                                 (default
                                                 "default-is-way-too-long-as-well")
            --baz string                         (default "default is a long string
                                                 that splits into multiple lines")
        -f, --foo-long-option-name string        Some multiline
                                                 description with newlines
            --quux string                        (permitted: one, two, three, four,
                                                 five, six, seven, eight, nine)
        -q, --qux-long-name string               Some description that
                                                 breaks into multiline
                                                 on newlines (permitted: one, two,
                                                 three, four, five, six) (default
                                                 "some long default on many lines")
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
          name "BARRRRR_VAR"
          default "some"
          desc "Some description"
        end

        env :baz do
          name "BAZ_VAR"
          desc "Some description"
          permit %w[a b c]
        end

        env :qux_var do
          name "A_VAR"
          desc "Some description"
        end

        env :fum do
          name "FUM_VAR"
        end

        env :quux do
          name "A_QUUUUUUX_VAR"
          hidden
        end
      end

      expected_output = unindent(<<-EOS)
      Usage: rspec command [OPTIONS] [ENVIRONMENT]

      Options:
        -f, --foo string  Some description

      Environment:
        A_VAR        Some description
        BARRRRR_VAR  Some description (default "some")
        BAZ_VAR      Some description (permitted: a, b, c)
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
      Usage: foo command

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
      Usage: foo command [OPTIONS] [ENVIRONMENT]

      Options:
        --bar  Some description

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

        argument :bar, required: true, desc: "Some argument description"

        keyword :baz, desc: "Some keyword description"

        flag :qux, desc: "Some option description"

        env :fum, desc: "Some env description"
      end

      expected_output = unindent(<<-EOS)
      CLI foo app

      Usage: foo command [OPTIONS] [ENVIRONMENT] BAR [BAZ=BAZ]

      Some foo app description

      Arguments:
        BAR  Some argument description

      Keywords:
        BAZ=BAZ  Some keyword description

      Options:
        --qux  Some option description

      Environment:
        FUM  Some env description

      Examples:
        Some example
        on multiline

      Run --help to see more info.
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "displays usage info using block" do
      cmd = new_command do
        usage do
          program "foo"
          command "cmd"
          header  "CLI foo app"
          desc    "Some foo app description"
          example "Some example", "on multiline"
          footer  "Run --help to see more info."
        end

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

      Usage: foo cmd [OPTIONS] [ENVIRONMENT] BAR [BAZ=BAZ]

      Some foo app description

      Arguments:
        BAR  Some argument description

      Keywords:
        BAZ=BAZ  Some keyword description

      Options:
        --qux  Some option description

      Environment:
        FUM  Some env description

      Examples:
        Some example
        on multiline

      Run --help to see more info.
      EOS

      expect(cmd.help).to eq(expected_output)
    end

    it "indents usage info" do
      cmd = new_command do
        usage do
          program "foo"
          header  "CLI foo app"
          desc    "Some foo app long description"
          example "Some example", "on multiline"
          footer  "Run --help to see more information"
        end

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

      expected_output = <<-EOS
  CLI foo app

  Usage: foo command [OPTIONS]
         [ENVIRONMENT] BAR
         [BAZ=BAZ]

  Some foo app long
  description

  Arguments:
    BAR  Some argument
         description

  Keywords:
    BAZ=BAZ  Some keyword
             description

  Options:
    --qux  Some option
           description

  Environment:
    FUM  Some env
         description

  Examples:
    Some example
    on multiline

  Run --help to see more
  information
      EOS

      expect(cmd.help(width: 30, indent: 2)).to eq(expected_output)
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
      Usage: foo command [OPTIONS] [ENVIRONMENT] Z D F [ZZ=ZZ] [DD=DD] [FF=FF]

      Arguments:
        Z  Some argument description
        D  Some argument description
        F  Some argument description

      Keywords:
        ZZ=ZZ  Some keyword description
        DD=DD  Some keyword description
        FF=FF  Some keyword description

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

    it "enumerates help content and yields to a block" do
      cmd = new_command do
        usage program: "foo",
              header: "CLI foo app",
              description: "Some foo app description",
              example: ["Some example", "on multiline"],
              footer: "Run --help to see more info."

        argument :bar, required: true, desc: "Some argument description"

        keyword :baz, desc: "Some keyword description"

        flag :qux, desc: "Some option description"

        env :fum, desc: "Some env description"
      end

      sections_help = nil

      cmd.help do |sections|
        sections_help = sections
      end

      expect(sections_help.to_a.map(&:to_a)).to eq([
        [:header, "CLI foo app\n"],
        [:banner, "Usage: foo command [OPTIONS] [ENVIRONMENT] BAR [BAZ=BAZ]"],
        [:description, "\nSome foo app description"],
        [:arguments, "\nArguments:\n  BAR  Some argument description"],
        [:keywords, "\nKeywords:\n  BAZ=BAZ  Some keyword description"],
        [:options, "\nOptions:\n  --qux  Some option description"],
        [:environments, "\nEnvironment:\n  FUM  Some env description"],
        [:examples, "\nExamples:\n  Some example\n  on multiline"],
        [:footer, "\nRun --help to see more info."]
      ])
    end

    it "modifies help sections before return" do
      cmd = new_command do
        usage program: "foo",
              header: "CLI foo app",
              description: "Some foo app description",
              example: ["Some example", "on multiline"],
              footer: "Run --help to see more info."

        argument :bar, required: true, desc: "Some argument description"
      end

      output = cmd.help do |sections|
        sections.delete :header

        sections.add_after :arguments, :commands,
                           "\nCommands:\n  create  A command description"

        sections.replace :footer, "\nGoodbye"
      end

      expected_output = unindent(<<-EOS)
      Usage: foo command BAR

      Some foo app description

      Arguments:
        BAR  Some argument description

      Commands:
        create  A command description

      Examples:
        Some example
        on multiline

      Goodbye
      EOS
      expect(output).to eq(expected_output)
    end
  end
end
