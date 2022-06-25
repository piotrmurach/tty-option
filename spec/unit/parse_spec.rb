# frozen_string_literal: true

RSpec.describe TTY::Option do
  context "argument" do
    it "doesn't allow to register same name parameter" do
      expect {
        command do
          argument :foo

          keyword :foo
        end
      }.to raise_error(TTY::Option::ParameterConflict,
                       "already registered parameter :foo")
    end

    it "reads a single argument" do
      cmd = new_command do
        argument :foo
      end

      cmd.parse(%w[bar])

      expect(cmd.params[:foo]).to eq("bar")
    end

    it "marks argument to be required by default" do
      cmd = new_command do
        argument :foo
      end

      cmd.parse([])

      expect(cmd.params.errors.messages).to eq([
        "argument 'foo' must be provided"
      ])
    end

    it "defauls argument to a value when optional" do
      cmd = new_command do
        argument(:foo) do
          optional
          default "bar"
        end
      end

      cmd.parse([])

      expect(cmd.params[:foo]).to eq("bar")
    end

    it "defauls argument to a proc when optional" do
      cmd = new_command do
        argument(:foo) do
          optional
          default -> { "bar" }
        end
      end

      cmd.parse([])

      expect(cmd.params[:foo]).to eq("bar")
    end

    it "reads an argument with exact number of values" do
      cmd = new_command do
        argument(:foo) { arity 3 }

        argument :bar
      end

      cmd.parse(%w[x y z w])

      expect(cmd.params["foo"]).to eq(%w[x y z])
      expect(cmd.params[:bar]).to eq("w")
    end

    it "doesn't permit 0 argument arity" do
      expect {
        command do
          argument :foo, arity: 0
        end
      }.to raise_error(TTY::Option::ConfigurationError,
                       "argument 'foo' arity cannot be zero")
    end

    it "fails to parse no argument when requiring exactly two" do
      cmd = new_command do
        argument(:foo) { arity 2 }

        argument :bar
      end

      expect {
        cmd.parse(%w[], raise_on_parse_error: true)
      }.to raise_error(TTY::Option::MissingParameter,
                       "argument 'foo' must be provided")
    end

    it "reads zero or more values with zero_or_more arity" do
      cmd = new_command do
        argument :foo, arity: zero_or_more
      end

      cmd.parse(%w[x y z w])

      expect(cmd.params[:foo]).to eq(%w[x y z w])
    end

    it "reads no values with zero_or_more arity" do
      cmd = new_command do
        argument(:foo) { arity zero_or_more }
      end

      cmd.parse([])

      expect(cmd.params[:foo]).to eq(nil)
    end

    it "reads one or more values one_or_more arity" do
      cmd = new_command do
        argument(:foo) { arity one_or_more }
      end

      cmd.parse(%w[x y z w])

      expect(cmd.params[:foo]).to eq(%w[x y z w])
    end

    it "reads at least 3 or more values with at_least arity" do
      cmd = new_command do
        argument(:foo) { arity at_least(3) }
      end

      cmd.parse(%w[x y z w])

      expect(cmd.params[:foo]).to eq(%w[x y z w])
    end

    it "fails to read the minimum number of values with arity" do
      cmd = new_command do
        argument(:foo) { arity at_least(3) }
      end

      expect {
        cmd.parse(%w[x y], raise_on_parse_error: true)
      }.to raise_error(TTY::Option::InvalidArity,
                       "argument 'foo' should appear at least 3 times but " \
                       "appeared 2 times")
    end

    it "reads no argument for zero_or_more arity and list conversion" do
      cmd = new_command do
        argument(:foo) do
          arity zero_or_more
          convert :list
        end
      end

      cmd.parse([], raise_on_parse_error: true)

      expect(cmd.params[:foo]).to eq(nil)
    end

    it "fails to parse no argument for one_or_more arity and list conversion" do
      cmd = new_command do
        argument(:foo) do
          arity one_or_more
          convert :list
        end
      end

      expect {
        cmd.parse([], raise_on_parse_error: true)
      }.to raise_error(TTY::Option::InvalidArity,
                       "argument 'foo' should appear at least 1 time but " \
                       "appeared 0 times")
    end

    it "reads two or more value and converts to map" do
      cmd = new_command do
        argument :foo do
          arity two_or_more
          convert :int_map
        end
      end

      cmd.parse(%w[a:1 b:2 c:3])

      expect(cmd.params[:foo]).to eq({a: 1, b: 2, c: 3})
    end

    it "fails to parse map due to validation rule" do
      cmd = new_command do
        argument :foo do
          arity one_or_more
          convert :int_map
          validate ->(val) { val[1] < 3 }
        end
      end

      expect {
        cmd.parse(%w[a:1 b:2 c:3], raise_on_parse_error: true)
      }.to raise_error(TTY::Option::InvalidArgument,
                       "value of `[:c, 3]` fails validation for 'foo' argument")
    end

    it "doesn't raise on a validation rule failure and reads an error message" do
      cmd = new_command do
        argument :foo do
          convert :int
          validate ->(val) { val < 10 }
        end
      end

      cmd.parse(%w[11])

      expect(cmd.params.errors.messages).to eq([
        "value of `11` fails validation for 'foo' argument"
      ])
    end

    it "doesn't validate the optional argument when no value is provided" do
      cmd = new_command do
        argument :foo do
          optional
          validate ->(val) { val == "bar" }
        end
      end

      cmd.parse([])

      expect(cmd.params[:foo]).to eq(nil)
      expect(cmd.params.errors.messages).to eq([])
    end

    it "doesn't raise on a conversion failure and reads an error message" do
      cmd = new_command do
        argument :foo do
          convert :int
        end
      end

      cmd.parse(%w[bar])

      expect(cmd.params[:foo]).to eq(nil)
      expect(cmd.params.errors.messages).to eq([
        "cannot convert value of `bar` into 'int' type for 'foo' argument"
      ])
    end

    it "doesn't permit a value" do
      cmd = new_command do
        argument :foo do
          convert :int
          permit [11, 12, 13]
        end
      end

      expect {
        cmd.parse(%w[14], raise_on_parse_error: true)
      }.to raise_error(TTY::Option::UnpermittedArgument,
                       "unpermitted value `14` for 'foo' argument: "\
                       "choose from 11, 12, 13")
    end

    it "doesn't raise on an unpermitted value and reads error message" do
      cmd = new_command do
        argument :foo do
          convert :int
          permit [11, 12, 13]
        end
      end

      cmd.parse(%w[14])

      expect(cmd.params.errors.messages).to eq([
        "unpermitted value `14` for 'foo' argument: choose from 11, 12, 13"
      ])
    end

    it "doesn't check permitted values when optional and no value is provided" do
      cmd = new_command do
        argument :foo do
          optional
          permit %w[bar baz]
        end
      end

      cmd.parse([], raise_on_parse_error: true)

      expect(cmd.params[:foo]).to eq(nil)
    end
  end

  context "keyword" do
    it "reads a keyword with a single value" do
      cmd = new_command do
        keyword :foo

        keyword :bar
      end

      cmd.parse(%w[foo=x bar=12])

      expect(cmd.params[:foo]).to eq("x")
      expect(cmd.params[:bar]).to eq("12")
    end

    it "changes keyword name" do
      cmd = new_command do
        keyword :foo do
          name "fum"
        end
      end

      cmd.parse(%w[fum=x])

      expect(cmd.params[:foo]).to eq("x")
    end

    it "collects multiple keyword occurences" do
      cmd = new_command do
        keyword :foo, arity: 2

        keyword :bar, convert: :int
      end

      cmd.parse(%w[foo=x bar=12 foo=y])

      expect(cmd.params[:foo]).to eq(%w[x y])
      expect(cmd.params[:bar]).to eq(12)
    end

    it "collects multiple keyword occurences and converts" do
      cmd = new_command do
        keyword(:foo) do
          arity 2
          convert :int
        end

        keyword(:bar) do
          convert :int
        end
      end

      cmd.parse(%w[foo=11 bar=12 foo=13])

      expect(cmd.params[:foo]).to eq([11, 13])
      expect(cmd.params[:bar]).to eq(12)
    end

    it "fails to parse a keyword due to validation rule" do
      cmd = new_command do
        keyword :foo do
          arity one_or_more
          convert :int
          validate ->(val) { val < 12 }
        end
      end

      expect {
        cmd.parse(%w[foo=11 foo=13], raise_on_parse_error: true)
      }.to raise_error(TTY::Option::InvalidArgument,
                       "value of `13` fails validation for 'foo' keyword")
    end

    it "doesn't permit a value" do
      cmd = new_command do
        keyword :foo do
          convert :int
          permit [11, 12, 13]
        end
      end

      expect {
        cmd.parse(%w[foo=14], raise_on_parse_error: true)
      }.to raise_error(TTY::Option::UnpermittedArgument,
                       "unpermitted value `14` for 'foo' keyword: " \
                       "choose from 11, 12, 13")
    end

    it "requires a keyword presence" do
      cmd = new_command do
        keyword :foo do
          required
        end
      end

      expect {
        cmd.parse([], raise_on_parse_error: true)
      }.to raise_error(TTY::Option::MissingParameter,
                       "keyword 'foo' must be provided")
    end
  end

  context "env" do
    it "reads an env variable from command line" do
      cmd = new_command do
        env(:foo) { convert :int }

        env(:bar) { convert :bools }

        env(:baz) do
          name "FOOBAR"
          convert :sym
        end

        env(:qux) do
          default "x"
          convert ->(val) { val.upcase }
        end
      end

      cmd.parse(%w[FOOBAR=foobar BAR=t,f,t FOO=12])

      expect(cmd.params[:foo]).to eq(12)
      expect(cmd.params[:bar]).to eq([true, false, true])
      expect(cmd.params[:baz]).to eq(:foobar)
      expect(cmd.params[:qux]).to eq("X")
    end

    it "reads an env variable from ENV hash" do
      cmd = new_command do
        env :foo, convert: :int

        env :bar, convert: list_of(:bool)

        env :baz, name: "FOOBAR", convert: :sym
      end

      cmd.parse([], {"FOO" => "12", "BAR" => "t,f,t", "FOOBAR" => "foobar"})

      expect(cmd.params[:foo]).to eq(12)
      expect(cmd.params[:bar]).to eq([true, false, true])
      expect(cmd.params[:baz]).to eq(:foobar)
    end

    it "fails to assign value due to validation" do
      cmd = new_command do
        env(:foo) do
          convert :int_list
          validate ->(val) { val < 14 }
        end
      end

      expect {
        cmd.parse(%w[FOO=10,12,14], raise_on_parse_error: true)
      }.to raise_error(TTY::Option::InvalidArgument,
                       "value of `14` fails validation for 'FOO' environment")
    end

    it "doesn't permit a value" do
      cmd = new_command do
        env :foo do
          convert :int
          permit [11, 12, 13]
        end
      end

      expect {
        cmd.parse(%w[FOO=14], raise_on_parse_error: true)
      }.to raise_error(TTY::Option::UnpermittedArgument,
                       "unpermitted value `14` for 'FOO' environment: " \
                       "choose from 11, 12, 13")
    end

    it "requires an env variable presence" do
      cmd = new_command do
        env :foo, required: true
      end

      expect {
        cmd.parse([], {}, raise_on_parse_error: true)
      }.to raise_error(TTY::Option::MissingParameter,
                       "environment 'FOO' must be provided")
    end
  end

  context "option" do
    it "reads a switch" do
      cmd = new_command do
        flag :foo
      end

      cmd.parse(%w[--foo])

      expect(cmd.params[:foo]).to eq(true)
    end

    it "reads an option with short, long & desc as hash options" do
      cmd = new_command do
        option :foo do
          arity one_or_more
          short "-b"
          long "--bar string"
        end
      end

      cmd.parse(%w[--bar baz -b qux])

      expect(cmd.params[:foo]).to eq(%w[baz qux])
    end

    it "doens't require options by default" do
      cmd = new_command do
        option :foo do
          long "--foo string"
        end
      end

      cmd.parse([])

      expect(cmd.params[:foo]).to eq(nil)
    end

    it "requires an option to be present" do
      cmd = new_command do
        option :foo do
          required
          long "--foo string"
        end
      end

      expect {
        cmd.parse([], raise_on_parse_error: true)
      }.to raise_error(TTY::Option::MissingParameter,
                       "option '--foo' must be provided")
    end

    it "marks an option as optional with required argument" do
      cmd = new_command do
        option :foo do
          optional
          long "--foo string"
        end
      end

      cmd.parse([])

      expect(cmd.params[:foo]).to eq(nil)
    end

    it "requires an option to have an argument" do
      cmd = new_command do
        option :foo, long: "--foo string"
      end

      expect {
        cmd.parse(%w[--foo], raise_on_parse_error: true)
      }.to raise_error(TTY::Option::MissingArgument)
    end

    it "doesn't accept duplicate short option" do
      expect {
        new_command do
          option :foo, short: "-f"
          option :fum, short: "-f"
        end
      }.to raise_error(TTY::Option::ParameterConflict,
                       "already registered short option -f")
    end

    it "doesn't accept duplicate long option" do
      expect {
        new_command do
          option :foo, long: "--foo"
          option :fum, long: "--foo"
        end
      }.to raise_error(TTY::Option::ParameterConflict,
                       "already registered long option --foo")
    end

    context "default" do
      it "defaults to a value with settings" do
        cmd = new_command do
          option :foo, long: "--foo VAL", default: "bar"
        end

        cmd.parse([])

        expect(cmd.params[:foo]).to eq("bar")
      end

      it "defaults to a proc value via DSL" do
        cmd = new_command do
          option :foo do
            long "--foo VAL"
            default -> { "bar" }
          end
        end

        cmd.parse([])

        expect(cmd.params[:foo]).to eq("bar")
      end
    end

    context "convert" do
      it "converts option value to expected type" do
        cmd = new_command do
          option :foo, long: "--foo VAL", convert: :int

          option :bar, long: "--bar VAL", convert: :bool

          option :baz, long: "--baz VAL", convert: ->(val) { val.to_s.upcase }

          option :qux, long: "--qux VAL", convert: :list

          option :fum, long: "--fum VAL", convert: :ints
        end

        cmd.parse(%w[--foo 12 --bar yes --baz foo --qux a,b,c --fum 1 2 3])

        expect(cmd.params[:foo]).to eq(12)
        expect(cmd.params[:bar]).to eq(true)
        expect(cmd.params[:baz]).to eq("FOO")
        expect(cmd.params[:qux]).to eq(%w[a b c])
        expect(cmd.params[:fum]).to eq([1, 2, 3])
      end

      it "handles option maps with & connector" do
        cmd = new_command do
          option :foo do
            long "--foo VAL"
            convert :map
          end

          option :bar do
            long "--bar=VAL"
            convert map_of(Integer)
          end
        end

        cmd.parse(%w[--foo a=1&b=2&a=3 --bar c:1&d:2])

        expect(cmd.params[:foo]).to eq({a: %w[1 3], b: "2"})
        expect(cmd.params[:bar]).to eq({c: 1, d: 2})
      end

      it "handles option maps with space and :/= delimiters" do
        cmd = new_command do
          option :foo do
            long "--foo VAL"
            convert :map
          end

          option :bar do
            long "--bar=VAL"
            convert :int_map
          end
        end

        cmd.parse(%w[--foo a=1 b=2 a=3 --bar c:1 d:2])

        expect(cmd.params[:foo]).to eq({a: %w[1 3], b: "2"})
        expect(cmd.params[:bar]).to eq({c: 1, d: 2})
      end
    end

    context "permit" do
      it "permits an allowed value" do
        cmd = new_command do
          option :foo do
            long "--foo VAL"
            convert :sym
            permit %i[bar baz qux]
          end
        end

        cmd.parse(%w[--foo qux])

        expect(cmd.params[:foo]).to eq(:qux)
      end

      it "doesn't permit a value" do
        cmd = new_command do
          option :foo do
            long "--foo VAL"
            convert :int
            permit [11, 12, 13]
          end
        end

        expect {
          cmd.parse(%w[--foo 14], raise_on_parse_error: true)
        }.to raise_error(TTY::Option::UnpermittedArgument,
                         "unpermitted value `14` for '--foo' option: " \
                         "choose from 11, 12, 13")
      end

      it "permits no value" do
        cmd = new_command do
          option :foo do
            long "--foo VAL"
            permit %w[bar baz qux]
          end
        end

        cmd.parse([], raise_on_parse_error: true)

        expect(cmd.params[:foo]).to eq(nil)
      end
    end

    context "validate" do
      it "validates an option with a custom proc" do
        cmd = new_command do
          option :foo do
            long "--foo VAL"
            convert Integer
            validate ->(val) { val == 12 }
          end
        end

        expect {
          cmd.parse(%w[--foo 13], raise_on_parse_error: true)
        }.to raise_error(TTY::Option::InvalidArgument,
                         "value of `13` fails validation for '--foo' option")
      end

      it "validates an option with a string as regex" do
        cmd = new_command do
          option :foo do
            long "--foo VAL"
            validate "\d+"
          end
        end

        expect {
          cmd.parse(%w[--foo bar], raise_on_parse_error: true)
        }.to raise_error(TTY::Option::InvalidArgument,
                         "value of `bar` fails validation for '--foo' option")
      end

      it "validates an option with a multiple argument" do
        cmd = new_command do
          option :foo do
            long "--foo VAL"
            convert :int_list
            validate ->(val) { val < 12 }
          end
        end

        expect {
          cmd.parse(%w[--foo 10,11,12], raise_on_parse_error: true)
        }.to raise_error(TTY::Option::InvalidArgument,
                         "value of `12` fails validation for '--foo' option")
      end
    end
  end

  context "when mixed parameters" do
    it "parses a complex command" do
      cmd = new_command do
        argument :action

        argument :image

        keyword :restart do
          default "no"
          permit %w[no on-failure always unless-stopped]
        end

        flag :detach do
          short "-d"
          long "--detach"
        end

        option :name do
          required
          long "--name string"
        end

        option :port do
          short "-p"
          long "--publish list"
          convert :list
        end

        env :cmd_env do
          default "development"
        end
      end

      cmd.parse(%w[
        CMD_ENV=production run restart=always -d -p 5000:3000 5001:8080 --name web ubuntu:16.4
      ])

      expect(cmd.params[:action]).to eq("run")
      expect(cmd.params[:image]).to eq("ubuntu:16.4")
      expect(cmd.params[:detach]).to eq(true)
      expect(cmd.params[:port]).to eq(%w[5000:3000 5001:8080])
      expect(cmd.params[:restart]).to eq("always")
      expect(cmd.params[:name]).to eq("web")
      expect(cmd.params[:cmd_env]).to eq("production")
    end

    it "collects errors from different parsers" do
      cmd = new_command do
        argument(:foo)

        keyword(:bar) { required }

        option(:baz) do
          required
          long "--baz string"
        end

        env(:qux) { required }
      end

      cmd.parse(%w[])

      expect(cmd.params.errors.messages).to eq([
        "option '--baz' must be provided",
        "keyword 'bar' must be provided",
        "argument 'foo' must be provided",
        "environment 'QUX' must be provided"
      ])
    end
  end

  context "when remaining arguments" do
    it "defaults remainng parameters" do
      cmd = new_command

      expect(cmd.params.to_h).to eq({})
      expect(cmd.params.remaining).to eq([])
      expect(cmd.params.errors.to_a).to eq([])
    end

    it "adds unparsed arguments to remaining" do
      cmd = new_command do
        argument :foo
      end

      cmd.parse(%w[a b c])

      expect(cmd.params[:foo]).to eq("a")
      expect(cmd.params.remaining).to eq(%w[b c])
    end

    it "adds unknown options to remaining when :check_invalid_params disabled" do
      cmd = new_command do
        option :foo
      end

      cmd.parse(%w[--foo --bar -c], check_invalid_params: false)

      expect(cmd.params[:foo]).to eq(true)
      expect(cmd.params.remaining).to eq(%w[--bar -c])
    end
  end

  context "when help" do
    it "parses help when parsing errors are not raised" do
      cmd = new_command do
        argument :foo

        flag :help do
          short "-h"
          long "--help"
        end

        option :bar do
          required
          short "-b"
          long "--bar string"
        end
      end

      cmd.parse(%w[a --help])

      expect(cmd.params[:foo]).to eq("a")
      expect(cmd.params[:bar]).to eq(nil)
      expect(cmd.params[:help]).to eq(true)
      expect(cmd.params.errors.messages).to eq(["option '--bar' must be provided"])
      expect(cmd.params.remaining).to eq(%w[])
    end
  end

  context "stops parsing on --" do
    it "doesn't include arguments -- split" do
      cmd = new_command

      cmd.parse(%w[--])

      expect(cmd.params).to be_empty
      expect(cmd.params.remaining).to eq([])
    end

    it "doesn't include arguments after --- split" do
      cmd = new_command

      cmd.parse(%w[--- a b])

      expect(cmd.params).to be_empty
      expect(cmd.params.remaining).to eq(%w[a b])
    end

    it "parses anything after -- as remaining arguments" do
      cmd = new_command do
        option :foo do
          arity one_or_more
          short "-f"
          long "--foo list"
          convert :list
        end

        option :bar do
          optional
          short "-b"
          long "--bar string"
        end
      end

      cmd.parse(%w[--foo a b -- --bar c d])

      expect(cmd.params[:foo]).to eq(%w[a b])
      expect(cmd.params.remaining).to eq(%w[--bar c d])
    end
  end
end
