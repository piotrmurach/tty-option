# frozen_string_literal: true

RSpec.describe TTY::Option::Parameter::Option do
  it "generates a default optional long name" do
    option = described_class.new(:foo)

    expect(option.name).to eq(:foo)
    expect(option.short).to eq(nil)
    expect(option.short?).to eq(false)
    expect(option.long).to eq("--foo")
    expect(option.long_name).to eq("--foo")
    expect(option.long?).to eq(true)

    expect(option.required?).to eq(false)
    expect(option.optional?).to eq(true)
    expect(option.argument_required?).to eq(false)
    expect(option.argument_optional?).to eq(false)
  end

  context "arity setting" do
    it "defaults to 1" do
      arg = described_class.new(:foo)
      expect(arg.arity).to eq(1)
      expect(arg.multiple?).to eq(false)
    end
  end

  context "default setting" do
    it "defaults to nil for shortcut option" do
      option = described_class.new(:foo)

      expect(option.default).to eq(nil)
    end

    it "defaults to nil for options without arguments" do
      option = described_class.new(:foo, short: "-f", long: "--foo")

      expect(option.default).to eq(nil)
    end

    it "defaults to nil for options with arguments" do
      option = described_class.new(:foo, short: "-f", long: "--foo string")

      expect(option.default).to eq(nil)
    end
  end

  context "when multi argument" do
    it "converts to a list" do
      option = described_class.new(:foo, short: "-f string", convert: :list)

      expect(option.multi_argument?).to eq(true)
    end

    it "converts to a list" do
      option = described_class.new(:foo, short: "-f string", convert: :bools)

      expect(option.multi_argument?).to eq(true)
    end

    it "converts to a map" do
      option = described_class.new(:foo, short: "-f string", convert: :map)

      expect(option.multi_argument?).to eq(true)
    end
  end

  context "short setting" do
    it "extracts a short name without argument" do
      option = described_class.new(:foo, short: "-f")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq("-f")
      expect(option.short?).to eq(true)
      expect(option.long).to eq(nil)
      expect(option.long_name).to eq("")
      expect(option.long?).to eq(false)

      expect(option.required?).to eq(false)
      expect(option.optional?).to eq(true)
      expect(option.argument_required?).to eq(false)
      expect(option.argument_optional?).to eq(false)
    end

    it "extracts a short name with argument" do
      option = described_class.new(:foo, short: "-f string")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq("-f string")
      expect(option.short_name).to eq("-f")
      expect(option.short?).to eq(true)
      expect(option.long).to eq(nil)
      expect(option.long_name).to eq("")
      expect(option.long?).to eq(false)

      expect(option.required?).to eq(true)
      expect(option.optional?).to eq(false)
      expect(option.argument_required?).to eq(true)
      expect(option.argument_optional?).to eq(false)
    end

    it "extracts a short name with argument glued together" do
      option = described_class.new(:foo, short: "-fstring")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq("-fstring")
      expect(option.short_name).to eq("-f")
      expect(option.short?).to eq(true)
      expect(option.long).to eq(nil)
      expect(option.long_name).to eq("")
      expect(option.long?).to eq(false)

      expect(option.required?).to eq(true)
      expect(option.optional?).to eq(false)
      expect(option.argument_required?).to eq(true)
      expect(option.argument_optional?).to eq(false)
    end

    it "extracts a short name with an optional argument" do
      option = described_class.new(:foo, short: "-f [string]")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq("-f [string]")
      expect(option.short_name).to eq("-f")
      expect(option.short?).to eq(true)
      expect(option.long).to eq(nil)
      expect(option.long?).to eq(false)

      expect(option.required?).to eq(false)
      expect(option.optional?).to eq(true)
      expect(option.argument_required?).to eq(false)
      expect(option.argument_optional?).to eq(true)
    end

    it "extracts a short name with an optional argument glued together" do
      option = described_class.new(:foo, short: "-f[string]")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq("-f[string]")
      expect(option.short_name).to eq("-f")
      expect(option.short?).to eq(true)
      expect(option.long).to eq(nil)
      expect(option.long?).to eq(false)

      expect(option.required?).to eq(false)
      expect(option.optional?).to eq(true)
      expect(option.argument_required?).to eq(false)
      expect(option.argument_optional?).to eq(true)
    end
  end

  context "long setting" do
    it "extracts a long name without argument" do
      option = described_class.new(:foo, long: "--foo")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq(nil)
      expect(option.short?).to eq(false)
      expect(option.long).to eq("--foo")
      expect(option.long_name).to eq("--foo")
      expect(option.long?).to eq(true)

      expect(option.required?).to eq(false)
      expect(option.optional?).to eq(true)
      expect(option.argument_required?).to eq(false)
      expect(option.argument_optional?).to eq(false)
    end

    it "extracts a long name with argument" do
      option = described_class.new(:foo, long: "--foo string")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq(nil)
      expect(option.short_name).to eq("")
      expect(option.short?).to eq(false)
      expect(option.long).to eq("--foo string")
      expect(option.long_name).to eq("--foo")
      expect(option.long?).to eq(true)

      expect(option.required?).to eq(true)
      expect(option.optional?).to eq(false)
      expect(option.argument_required?).to eq(true)
      expect(option.argument_optional?).to eq(false)
    end

    it "extracts a long name with argument separted with =" do
      option = described_class.new(:foo, long: "--foo=string")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq(nil)
      expect(option.short_name).to eq("")
      expect(option.short?).to eq(false)
      expect(option.long).to eq("--foo=string")
      expect(option.long_name).to eq("--foo")
      expect(option.long?).to eq(true)

      expect(option.required?).to eq(true)
      expect(option.optional?).to eq(false)
      expect(option.argument_required?).to eq(true)
      expect(option.argument_optional?).to eq(false)
    end

    it "extracts a long name with an optional argument" do
      option = described_class.new(:foo, long: "--foo [string]")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq(nil)
      expect(option.short_name).to eq("")
      expect(option.short?).to eq(false)
      expect(option.long).to eq("--foo [string]")
      expect(option.long_name).to eq("--foo")
      expect(option.long?).to eq(true)

      expect(option.required?).to eq(false)
      expect(option.optional?).to eq(true)
      expect(option.argument_required?).to eq(false)
      expect(option.argument_optional?).to eq(true)
    end

    it "extracts a short name with an optional argument glued together" do
      option = described_class.new(:foo, long: "--foo[string]")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq(nil)
      expect(option.short_name).to eq("")
      expect(option.short?).to eq(false)
      expect(option.long).to eq("--foo[string]")
      expect(option.long_name).to eq("--foo")
      expect(option.long?).to eq(true)

      expect(option.required?).to eq(false)
      expect(option.optional?).to eq(true)
      expect(option.argument_required?).to eq(false)
      expect(option.argument_optional?).to eq(true)
    end
  end

  context "short & long setting" do
    it "extracts a short & long name with a required argument for long option" do
      option = described_class.new(:foo, short: "-f", long: "--foo string")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq("-f")
      expect(option.short_name).to eq("-f")
      expect(option.short?).to eq(true)
      expect(option.long).to eq("--foo string")
      expect(option.long_name).to eq("--foo")
      expect(option.long?).to eq(true)

      expect(option.required?).to eq(true)
      expect(option.optional?).to eq(false)
      expect(option.argument_required?).to eq(true)
      expect(option.argument_optional?).to eq(false)
    end

    it "extracts a short & long name with a required argument for short option" do
      option = described_class.new(:foo, short: "-f string", long: "--foo")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq("-f string")
      expect(option.short_name).to eq("-f")
      expect(option.short?).to eq(true)
      expect(option.long).to eq("--foo")
      expect(option.long_name).to eq("--foo")
      expect(option.long?).to eq(true)

      expect(option.required?).to eq(true)
      expect(option.optional?).to eq(false)
      expect(option.argument_required?).to eq(true)
      expect(option.argument_optional?).to eq(false)
    end

    it "extracts a short & long name with an optional argument for long option" do
      option = described_class.new(:foo, short: "-f", long: "--foo [string]")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq("-f")
      expect(option.short_name).to eq("-f")
      expect(option.short?).to eq(true)
      expect(option.long).to eq("--foo [string]")
      expect(option.long_name).to eq("--foo")
      expect(option.long?).to eq(true)

      expect(option.required?).to eq(false)
      expect(option.optional?).to eq(true)
      expect(option.argument_required?).to eq(false)
      expect(option.argument_optional?).to eq(true)
    end

    it "extracts a short & long name with an optional argument for short option" do
      option = described_class.new(:foo, short: "-f [string]", long: "--foo")

      expect(option.name).to eq(:foo)
      expect(option.short).to eq("-f [string]")
      expect(option.short_name).to eq("-f")
      expect(option.short?).to eq(true)
      expect(option.long).to eq("--foo")
      expect(option.long_name).to eq("--foo")
      expect(option.long?).to eq(true)

      expect(option.required?).to eq(false)
      expect(option.optional?).to eq(true)
      expect(option.argument_required?).to eq(false)
      expect(option.argument_optional?).to eq(true)
    end
  end
end
