# frozen_string_literal: true

RSpec.describe TTY::Option::Parameter::Argument do
  it "converts class to symbol name" do
    arg = described_class.new(:foo)

    expect(arg.to_sym).to eq(:argument)
  end

  it "has no settings by default" do
    arg = described_class.new(:foo)

    expect(arg.to_h).to eq({})
  end

  context "arity setting" do
    it "defaults to 1" do
      arg = described_class.new(:foo)
      expect(arg.arity).to eq(1)
      expect(arg.min_arity).to eq(1)
      expect(arg.multiple?).to eq(false)
    end

    it "is invalid when nil" do
      expect {
        described_class.new(:foo, arity: nil)
      }.to raise_error(TTY::Option::InvalidArity,
                       "argument :foo expects an integer value for arity")
    end

    it "is invalid when 0" do
      expect {
        described_class.new(:foo, arity: 0)
      }.to raise_error(TTY::Option::InvalidArity,
                       "argument :foo arity cannot be zero")
    end

    it "accepts * as zero or more arity" do
      arg = described_class.new(:foo, arity: "*")
      expect(arg.arity).to eq(-1)
      expect(arg.min_arity).to eq(0)
      expect(arg.multiple?).to eq(true)
    end

    it "accepts :any as zero or more arity" do
      arg = described_class.new(:foo, arity: :any)
      expect(arg.arity).to eq(-1)
      expect(arg.min_arity).to eq(0)
      expect(arg.multiple?).to eq(true)
    end

    it "accepts one or more arity" do
      arg = described_class.new(:foo, arity: -2)
      expect(arg.arity).to eq(-2)
      expect(arg.min_arity).to eq(1)
      expect(arg.multiple?).to eq(true)
    end
  end

  context "default setting" do
    it "returns nil" do
      arg = described_class.new(:foo)

      expect(arg.default).to eq(nil)
      expect(arg.default?).to eq(false)
    end

    it "returns default value" do
      arg = described_class.new(:foo, default: "arg1")

      expect(arg.default).to eq("arg1")
      expect(arg.default?).to eq(true)
    end
  end

  context "description setting" do
    it "returns nil when not set" do
      arg = described_class.new(:foo)

      expect(arg.desc).to eq(nil)
      expect(arg.desc?).to eq(false)
    end

    it "returns description" do
      arg = described_class.new(:foo, desc: "Some description")

      expect(arg.desc).to eq("Some description")
      expect(arg.desc?).to eq(true)
    end
  end

  context "convert setting" do
    it "returns nil" do
      arg = described_class.new(:foo)

      expect(arg.convert).to eq(nil)
      expect(arg.convert?).to eq(false)
    end

    it "returns conversion value" do
      arg = described_class.new(:foo, convert: :int)

      expect(arg.convert).to eq(:int)
      expect(arg.convert?).to eq(true)
    end
  end

  context "required/optional setting" do
    it "doesn't require argument presence by default" do
      arg = described_class.new(:foo)

      expect(arg.required?).to eq(false)
      expect(arg.optional?).to eq(true)
    end

    it "returns default value" do
      arg = described_class.new(:foo, required: false)

      expect(arg.required?).to eq(false)
      expect(arg.optional?).to eq(true)
    end

    it "sets required to true with a method" do
      arg = described_class.new(:foo, required: false)

      arg.required

      expect(arg.required?).to eq(true)
      expect(arg.optional?).to eq(false)
    end

    it "sets required to true with a method" do
      arg = described_class.new(:foo, required: true)

      arg.optional

      expect(arg.required?).to eq(false)
      expect(arg.optional?).to eq(true)
    end
  end

  context "hidden setting" do
    it "doesn't hide argument from usage by default" do
      arg = described_class.new(:foo)

      expect(arg.hidden?).to eq(false)
    end

    it "hides argument from usage" do
      arg = described_class.new(:foo, hidden: true)

      expect(arg.hidden?).to eq(true)
    end
  end

  context "permit setting" do
    it "returns nil" do
      arg = described_class.new(:foo)

      expect(arg.permit).to eq(nil)
      expect(arg.permit?).to eq(false)
    end

    it "returns permitted list" do
      arg = described_class.new(:foo, permit: %w[a b c])

      expect(arg.permit).to eq(%w[a b c])
      expect(arg.permit?).to eq(true)
    end

    it "returns permitted set" do
      permitted = Set["a", "b", "c"]
      arg = described_class.new(:foo, permit: permitted)

      expect(arg.permit).to eq(permitted)
      expect(arg.permit?).to eq(true)
    end

    it "is invalid when nil" do
      expect {
        described_class.new(:foo, permit: nil)
      }.to raise_error(TTY::Option::InvalidPermitted,
                       "expects an Array type")
    end

    it "is invalid when not an array type" do
      expect {
        described_class.new(:foo, permit: Object.new)
      }.to raise_error(TTY::Option::InvalidPermitted,
                       "expects an Array type")
    end
  end

  context "validate setting" do
    it "returns nil" do
      arg = described_class.new(:foo)

      expect(arg.validate).to eq(nil)
      expect(arg.validate?).to eq(false)
    end

    it "returns validation value as proc" do
      validator = ->(val) { true }
      arg = described_class.new(:foo, validate: validator)

      expect(arg.validate).to eq(validator)
      expect(arg.validate?).to eq(true)
    end

    it "returns validation value as regexp" do
      arg = described_class.new(:foo, validate: "valid")

      expect(arg.validate).to eq(/valid/)
      expect(arg.validate?).to eq(true)
    end

    it "is invalid when nil" do
      expect {
        described_class.new(:foo, validate: nil)
      }.to raise_error(TTY::Option::InvalidValidation,
                       "expects a Proc or a Regexp value")
    end

    it "is invalid when not a proc or a regexp type" do
      expect {
        described_class.new(:foo, validate: Object.new)
      }.to raise_error(TTY::Option::InvalidValidation,
                       "only accepts a Proc or a Regexp type")
    end
  end

  context "comparison" do
    it "orders arguments by name" do
      option_foo = described_class.new(:foo)
      option_bar = described_class.new(:bar)
      option_baz = described_class.new(:baz)

      options = [option_foo, option_baz, option_bar]

      expect(options.sort).to eq([option_bar, option_baz, option_foo])
    end
  end

  context "equality" do
    it "compares different types" do
      option_foo = described_class.new(:foo)
      object = Object.new

      expect(option_foo).to_not eq(object)
      expect(option_foo).to_not equal(object)
    end

    it "compares different instances with the same name" do
      option_foo = described_class.new(:foo)
      option_foo_dupped = described_class.new(:foo).dup

      expect(option_foo).to eq(option_foo_dupped)
      expect(option_foo).to_not equal(option_foo_dupped)
    end

    it "compares different instances with different name" do
      option_foo = described_class.new(:foo)
      option_bar = described_class.new(:bar)

      expect(option_foo).to_not eq(option_bar)
      expect(option_foo).to_not equal(option_bar)
    end
  end

  context "variable setting" do
    it "defaults a variable to a parameter name with dashes" do
      arg = described_class.new(:foo_bar)

      expect(arg.variable).to eq("foo-bar")
    end

    it "sets a custom variable name via setting" do
      arg = described_class.new(:foo, variable: "foo-bar")

      expect(arg.variable).to eq("foo-bar")
    end

    it "sets a custom variable name via method" do
      arg = described_class.new(:foo)

      arg.variable "foo-bar"

      expect(arg.variable).to eq("foo-bar")
      expect(arg.var).to eq("foo-bar")
    end
  end

  context "dup argument instance" do
    it "duplicates argument settings provided as keywords" do
      arg = described_class.new(:foo, arity: 2, default: "bar", desc: "Some desc",
                                convert: :int, permit: %w[a b c], required: true)
      dupped_arg = arg.dup

      expect(dupped_arg).to eq(arg)
      expect(dupped_arg).to_not equal(arg)

      dupped_arg.arity(-3)
      expect(arg.arity).to eq(2)
      expect(dupped_arg.arity).to eq(-3)

      dupped_arg.default "baz"
      expect(arg.default).to eq("bar")
      expect(dupped_arg.default).to eq("baz")

      arg.desc "Some other"
      expect(arg.desc).to eq("Some other")
      expect(dupped_arg.desc).to eq("Some desc")

      arg.convert :list
      expect(arg.convert).to eq(:list)
      expect(dupped_arg.convert).to eq(:int)

      dupped_arg.permit << "d"
      expect(arg.permit).to eq(%w[a b c])
      expect(dupped_arg.permit).to eq(%w[a b c d])
    end

    it "duplicates argument settings provided via method calls" do
      arg = described_class.new(:foo) do
        required
        arity 2
        default "bar"
        desc "Some desc"
        convert :int
        permit %w[a b c]
      end

      dupped_arg = arg.dup

      expect(dupped_arg).to eq(arg)
      expect(dupped_arg).to_not equal(arg)

      dupped_arg.arity(-3)
      expect(arg.arity).to eq(2)
      expect(dupped_arg.arity).to eq(-3)

      dupped_arg.default "baz"
      expect(arg.default).to eq("bar")
      expect(dupped_arg.default).to eq("baz")

      arg.desc "Some other"
      expect(arg.desc).to eq("Some other")
      expect(dupped_arg.desc).to eq("Some desc")

      arg.convert :list
      expect(arg.convert).to eq(:list)
      expect(dupped_arg.convert).to eq(:int)

      dupped_arg.permit << "d"
      expect(arg.permit).to eq(%w[a b c])
      expect(dupped_arg.permit).to eq(%w[a b c d])
    end
  end

  context "to_h" do
    it "returns all settings as hash" do
      param = described_class.new(:foo) do
        variable "Variable"
        required
        arity 2
        convert :int
        default 11
        desc "Description"
        hidden
        permit [11, 12, 13]
        validate "\d+"
      end

      expect(param.to_h).to eq({
        arity: 2,
        convert: :int,
        default: 11,
        desc: "Description",
        hidden: true,
        permit: [11, 12, 13],
        required: true,
        validate: Regexp.new("\d+"),
        var: "Variable"
      })
    end

    it "transforms hash via a block" do
      param = described_class.new(:foo) do
        variable "Variable"
        required
        arity 2
        convert :int
        default 11
        desc "Description"
        hidden
        permit [11, 12, 13]
        validate "\d+"
      end

      transformed = param.to_h { |k, v| [k.to_s, v] }

      expect(transformed).to eq({
        "arity" => 2,
        "convert" => :int,
        "default" => 11,
        "desc" => "Description",
        "hidden" => true,
        "permit" => [11, 12, 13],
        "required" => true,
        "validate" => Regexp.new("\d+"),
        "var" => "Variable"
      })
    end
  end
end
