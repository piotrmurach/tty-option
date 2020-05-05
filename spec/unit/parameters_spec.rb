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

  context "delete" do
    it "deletes parameters from the list by name" do
      param_list = described_class.new

      argument_foo = new_parameter("argument", :foo)
      keyword_bar  = new_parameter("keyword", :bar)
      env_baz      = new_parameter("environment", :baz)
      option_qux   = new_parameter("option", :qux, short: "-q", long: "--qux")

      param_list << argument_foo << keyword_bar << env_baz << option_qux

      deleted_params = param_list.delete(:foo, :bar, :baz, :qux)

      expect(deleted_params).to eq([argument_foo, keyword_bar, env_baz, option_qux])
      expect(param_list.to_a).to eq([])
      expect(param_list.arguments).to eq([])
      expect(param_list.keywords).to eq([])
      expect(param_list.environments).to eq([])
      expect(param_list.options).to eq([])

      param_list << argument_foo << keyword_bar << env_baz << option_qux
      expect(param_list.to_a).to eq([argument_foo, keyword_bar, env_baz, option_qux])
      expect(param_list.arguments).to eq([argument_foo])
      expect(param_list.keywords).to eq([keyword_bar])
      expect(param_list.environments).to eq([env_baz])
      expect(param_list.options).to eq([option_qux])
    end

    it "deletes option from a cloned list" do
      param_list = described_class.new

      option_foo = new_parameter("option", :foo, long: "--foo")
      option_bar = new_parameter("option", :bar, long: "--bar")
      option_baz = new_parameter("option", :baz, long: "--baz")

      param_list << option_foo << option_bar

      new_list = param_list.dup
      new_list.delete(:bar)
      new_list << option_baz

      expect(new_list.to_a).to eq([option_foo, option_baz])
      expect(new_list.options).to eq([option_foo, option_baz])
    end
  end

  context "dup parameters" do
    it "duplicates parameters instance with all the collections" do
      param_list = described_class.new

      argument = new_parameter("argument", :foo)
      keyword = new_parameter("keyword", :bar)
      option = new_parameter("option", :baz)
      env = new_parameter("environment", :qux)

      param_list << argument
      param_list << keyword
      param_list << option
      param_list << env

      dupped_list = param_list.dup
      expect(dupped_list).to_not equal(param_list)
      expect(dupped_list.map(&:name)).to eq(param_list.map(&:name))

      argument2 = new_parameter("argument", :foo2)
      keyword2 = new_parameter("keyword", :bar2)
      option2 = new_parameter("option", :baz2)
      env2 = new_parameter("environment", :qux2)

      dupped_list << argument2
      dupped_list << keyword2
      dupped_list << option2
      dupped_list << env2

      expect(param_list.map(&:name)).to eq([:foo, :bar, :baz, :qux])
      expect(dupped_list.map(&:name)).to eq([:foo, :bar, :baz, :qux,
                                             :foo2, :bar2, :baz2, :qux2])

    end
  end
end
