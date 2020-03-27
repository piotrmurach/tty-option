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
      expect(arg.multiple?).to eq(false)
    end

    it "is invalid when nil" do
      expect {
        described_class.new(:foo, arity: nil)
      }.to raise_error(TTY::Option::InvalidArity, "expects an integer value")
    end

    it "is invalid when 0" do
      expect {
        described_class.new(:foo, arity: 0)
      }.to raise_error(TTY::Option::InvalidArity, "cannot be zero")
    end

    it "accepts * as zero or more arity" do
      arg = described_class.new(:foo, arity: "*")
      expect(arg.arity).to eq(-1)
      expect(arg.multiple?).to eq(true)
    end

    it "accepts :any as zero or more arity" do
      arg = described_class.new(:foo, arity: :any)
      expect(arg.arity).to eq(-1)
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

  context "required/optional setting" do
    it "requires argument presence by default" do
      arg = described_class.new(:foo)

      expect(arg.required?).to eq(true)
      expect(arg.optional?).to eq(false)
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
end
