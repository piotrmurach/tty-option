# frozen_string_literal: true

RSpec.describe TTY::Option do
  def command(&block)
    stub_const("Command", Class.new)
    Command.send :include, TTY::Option
    Command.class_eval(&block)
    Command
  end

  def new_command(&block)
    command(&block).new
  end

  it "doesn't allow to register same name parameter" do
    expect {
      command do
        argument :foo

        keyword :foo
      end
    }.to raise_error(TTY::Option::ParameterConflict,
                    "already registered parameter :foo")
  end

  context "argument" do
    it "reads a single argument" do
      cmd = new_command do
        argument :foo
      end

      cmd.parse(%w[bar])

      expect(cmd.params[:foo]).to eq("bar")
    end

    it "defaults argument to be required" do
      cmd = new_command do
        argument :foo
      end
      expect {
        cmd.parse([])
      }.to raise_error(TTY::Option::InvalidArity,
                       "expected argument :foo to appear 1 times " \
                       "but appeared 0 times")
    end

    it "defauls argument to a value" do
      cmd = new_command do
        argument(:foo) { default "bar" }
      end

      cmd.parse([])

      expect(cmd.params[:foo]).to eq("bar")
    end

    it "defauls argument to a proc" do
      cmd = new_command do
        argument(:foo) { default -> { "bar" } }
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

      expect(cmd.params[:foo]).to eq(%w[x y z])
      expect(cmd.params[:bar]).to eq("w")
    end

    it "doesn't permit 0 argument arity" do
      expect {
        command do
          argument :foo, arity: 0
        end
      }.to raise_error(TTY::Option::InvalidArity, "cannot be zero")
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
        cmd.parse(%w[x y])
      }.to raise_error(TTY::Option::InvalidArity,
                      "expected argument :foo to appear at least 3 times but " \
                      "appeared 2 times")
    end

    it "reads one or more value and converts to map" do
      cmd = new_command do
        argument :foo do
          arity one_or_more
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
        cmd.parse(%w[a:1 b:2 c:3])
      }.to raise_error(TTY::Option::InvalidArgument,
                "value of `[:c, 3]` fails validation rule for :foo parameter")
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
  end

  context "env" do
    it "reads an env variable from command line" do
      cmd = new_command do
        env(:foo) { convert :int }

        env(:bar) { convert :bools }

        env(:baz) do
          var "FOOBAR"
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

        env :bar, convert: :bools

        env :baz, variable: "FOOBAR", convert: :sym
      end

      cmd.parse([], {"FOO" => "12", "BAR" => "t,f,t", "FOOBAR" => "foobar"})

      expect(cmd.params[:foo]).to eq(12)
      expect(cmd.params[:bar]).to eq([true, false, true])
      expect(cmd.params[:baz]).to eq(:foobar)
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

      expect(cmd.params[:foo]).to eq(["baz", "qux"])
    end

    it "requires an option to have an argument" do
      cmd = new_command do
        option :foo, long: "--foo string"
      end

      expect {
        cmd.parse(%w[--foo])
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

          option :baz, long: "--baz VAL", convert: -> (val) { val.to_s.upcase }

          option :qux, long: "--qux VAL", convert: :list

          option :fum, long: "--fum VAL", convert: :ints
        end

        cmd.parse(%w[--foo 12 --bar yes --baz foo --qux a,b,c --fum 1 2 3])

        expect(cmd.params[:foo]).to eq(12)
        expect(cmd.params[:bar]).to eq(true)
        expect(cmd.params[:baz]).to eq("FOO")
        expect(cmd.params[:qux]).to eq(%w[a b c])
        expect(cmd.params[:fum]).to eq([1,2,3])
      end

      it "handles option maps with & connector" do
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

        cmd.parse(%w[--foo a=1&b=2&a=3 --bar c:1&d:2])

        expect(cmd.params[:foo]).to eq({a: ["1", "3"], b: "2"})
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

        expect(cmd.params[:foo]).to eq({a: ["1", "3"], b: "2"})
        expect(cmd.params[:bar]).to eq({c: 1, d: 2})
      end
    end

    context "validate" do
      it "validates an option with a custom proc" do
        cmd = new_command do
          option :foo do
            long "--foo VAL"
            convert Integer
            validate -> (val) { val == 12 }
          end
        end

        expect {
          cmd.parse(%w[--foo 13])
        }.to raise_error(TTY::Option::InvalidArgument,
                        "value of `13` fails validation rule for :foo parameter")
      end

      it "validates an option with a string as regex" do
        cmd = new_command do
          option :foo do
            long "--foo VAL"
            validate "\d+"
          end
        end

        expect {
          cmd.parse(%w[--foo bar])
        }.to raise_error(TTY::Option::InvalidArgument,
                        "value of `bar` fails validation rule for :foo parameter")
      end

      it "validates an option with a multiple argument" do
        cmd = new_command do
          option :foo do
            long "--foo VAL"
            convert :int_list
            validate -> (val) { val < 12 }
          end
        end

        expect {
          cmd.parse(%w[--foo 10,11,12])
        }.to raise_error(TTY::Option::InvalidArgument,
                         "value of `12` fails validation rule for :foo parameter")
      end
    end
  end
end
