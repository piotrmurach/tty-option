# frozen_string_literal: true

def command(&block)
  stub_const("Command", Class.new)
  Command.send :include, TTY::Option
  Command.class_eval(&block)
  Command
end

def new_command(&block)
  command(&block).new
end

RSpec.describe TTY::Option do
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
      expect(cmd.params[:bar]).to eq("12")
    end
  end

  context "env" do
    it "reads an env variable from command line" do
      cmd = new_command do
        env :foo

        env :bar

        env(:baz) { var "FOOBAR" }

        env(:qux) { default "x" }
      end

      cmd.parse(%w[FOOBAR=foobar BAR=true FOO=12])

      expect(cmd.params[:foo]).to eq("12")
      expect(cmd.params[:bar]).to eq("true")
      expect(cmd.params[:baz]).to eq("foobar")
      expect(cmd.params[:qux]).to eq("x")
    end

    it "reads an env variable from ENV hash" do
      cmd = new_command do
        env :foo

        env :bar

        env :baz, variable: "FOOBAR"
      end

      cmd.parse([], {"FOO" => "12", "BAR" => "true", "FOOBAR" => "foobar"})

      expect(cmd.params[:foo]).to eq("12")
      expect(cmd.params[:bar]).to eq("true")
      expect(cmd.params[:baz]).to eq("foobar")
    end
  end
end
