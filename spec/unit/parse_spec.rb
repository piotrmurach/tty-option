# frozen_string_literal: true

def command(&block)
  stub_const("Command", Class.new)
  Command.include(TTY::Option)
  Command.class_eval(&block)
  Command
end

RSpec.describe TTY::Option do
  context "argument" do
    it "reads a single argument" do
      command do
        argument :foo
      end

      cmd = Command.new
      argv = %w[bar]
      cmd.parse(argv)

      expect(cmd.params[:foo]).to eq("bar")
    end

    it "defauls argument to a value" do
      command do
        argument(:foo) { default "bar" }
      end

      cmd = Command.new
      cmd.parse([])

      expect(cmd.params[:foo]).to eq("bar")
    end

    it "defauls argument to a proc" do
      command do
        argument(:foo) { default -> { "bar" } }
      end

      cmd = Command.new
      cmd.parse([])

      expect(cmd.params[:foo]).to eq("bar")
    end

    it "reads an argument with exact number of values" do
      command do
        argument(:foo) { arity 3 }

        argument :bar
      end

      cmd = Command.new
      argv = %w[x y z w]
      cmd.parse(argv)

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
  end

  context "keyword" do
    it "reads a keyword with a single value" do
      command do
        keyword :foo

        keyword :bar
      end

      cmd = Command.new
      argv = %w[foo=x bar=12]
      cmd.parse(argv)

      expect(cmd.params[:foo]).to eq("x")
      expect(cmd.params[:bar]).to eq("12")
    end

    it "collects multiple keyword occurences" do
      command do
        keyword :foo, arity: 2

        keyword :bar, convert: :int
      end

      cmd = Command.new
      argv = %w[foo=x bar=12 foo=y]
      cmd.parse(argv)

      expect(cmd.params[:foo]).to eq(%w[x y])
      expect(cmd.params[:bar]).to eq("12")
    end
  end
end
