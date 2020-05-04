# frozen_string_literal: true

RSpec.describe TTY::Option::Parameters do
  context "accessors" do
    it "provides access to stored arguments" do
      param_list = described_class.new
      expect(param_list.arguments?).to eq(false)

      argument_foo = new_parameter("argument", :foo)
      argument_bar = new_parameter("argument", :bar)

      param_list << argument_foo
      param_list << argument_bar

      expect(param_list.arguments?).to eq(true)
      expect(param_list.arguments).to eq([argument_foo, argument_bar])
    end

    it "provides access to stored keywords" do
      param_list = described_class.new
      expect(param_list.keywords?).to eq(false)

      keyword_foo = new_parameter("keyword", :foo)
      keyword_bar = new_parameter("keyword", :bar)

      param_list << keyword_foo << keyword_bar

      expect(param_list.keywords?).to eq(true)
      expect(param_list.keywords).to eq([keyword_foo, keyword_bar])
    end

    it "provides access to stored options" do
      param_list = described_class.new
      expect(param_list.options?).to eq(false)

      option_foo = new_parameter("option", :foo)
      option_bar = new_parameter("option", :bar)

      param_list << option_foo << option_bar

      expect(param_list.options?).to eq(true)
      expect(param_list.options).to eq([option_foo, option_bar])
    end

    it "provides access to stored environments" do
      param_list = described_class.new
      expect(param_list.environments?).to eq(false)

      env_foo = new_parameter("environment", :foo)
      env_bar = new_parameter("environment", :bar)

      param_list << env_foo << env_bar

      expect(param_list.environments?).to eq(true)
      expect(param_list.environments).to eq([env_foo, env_bar])
    end
  end

  context "enumerable" do
    it "iterates over parameters list" do
      param_list = described_class.new

      argument = new_parameter("argument", :foo)
      keyword = new_parameter("keyword", :bar)
      option = new_parameter("option", :baz)
      env = new_parameter("environment", :qux)

      param_list << argument
      param_list << keyword
      param_list << option
      param_list << env

      expect(param_list.map(&:name)).to eq([:foo, :bar, :baz, :qux])
    end

    it "returns enumerable without a block" do
      param_list = described_class.new

      argument = new_parameter("argument", :foo)

      param_list << argument

      param_enum = param_list.each
      expect(param_enum.map(&:name)).to eq([:foo])
    end
  end
end
