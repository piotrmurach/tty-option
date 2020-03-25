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
  context "argument" do
    it "reads a single argument" do
      cmd = new_command do
        argument :foo
      end

      cmd.parse(%w[bar])

      expect(cmd.params[:foo]).to eq("bar")
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
end
