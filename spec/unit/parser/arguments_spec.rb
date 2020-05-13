# frozen_string_literal: true

RSpec.describe TTY::Option::Parser::Arguments do
  def arg(name, **settings)
    TTY::Option::Parameter::Argument.create(name, **settings)
  end

  def parse(argv, args, **config)
    parser = described_class.new(Array(args), **config)
    parser.parse(argv)
  end

  it "parses one argument by default" do
    params, rest = parse(%w[a], arg(:foo))

    expect(params[:foo]).to eq("a")
    expect(rest).to eq([])
  end

  it "parses exactly 2 arguments and leaves the rest" do
    params, rest = parse(%w[a b c], arg(:foo, arity: 2))

    expect(params[:foo]).to eq(%w[a b])
    expect(rest).to eq(%w[c])
  end

  it "doesn't find enough arguments to match specific arity" do
    expect {
      parse(%w[a], arg(:foo, arity: 2), raise_on_parse_error: true)
    }.to raise_error(TTY::Option::InvalidArity,
                     "argument 'foo' should appear 2 times but " \
                     "appeared 1 time")
  end

  it "doesn't find enough arguments to match at least arity" do
    expect {
      parse(%w[a], arg(:foo, arity: -3), raise_on_parse_error: true)
    }.to raise_error(TTY::Option::InvalidArity,
                     "argument 'foo' should appear at least 2 times but " \
                     "appeared 1 time")
  end

  it "doesn't find any arguments to match zero or more arity" do
    params, rest = parse([], arg(:foo, arity: :any))

    expect(params[:foo]).to eq(nil)
    expect(rest).to eq([])
  end

  it "raises if required argument isn't present" do
    expect {
      parse(%w[], arg(:foo, required: true), raise_on_parse_error: true)
    }.to raise_error(TTY::Option::MissingParameter,
                     "need to provide 'foo' argument")
  end

  it "accepts optional argument" do
    args = []
    args << arg(:foo, optional: true)
    args << arg(:bar, optional: true)
    params, rest = parse(%w[], args)

    expect(params[:foo]).to eq(nil)
    expect(params[:bar]).to eq(nil)
    expect(rest).to eq([])
  end

  it "collects errors when :raise_on_parsing_error is false" do
    args, rest, errors = parse(%w[a], arg(:foo, arity: 2))

    expect(args[:foo]).to eq("a")
    expect(rest).to eq([])
    expect(errors.map(&:message)).to eq([
      "argument 'foo' should appear 2 times but appeared 1 time"
    ])
  end

  it "parses zero or more arguments" do
    params, rest = parse(%w[a b c], arg(:foo, arity: "*"))

    expect(params[:foo]).to eq(%w[a b c])
    expect(rest).to eq([])
  end

  it "parses different arguments with different arities" do
    args = []
    args << arg(:foo, arity: 2)
    args << arg(:bar)
    args << arg(:baz, arity: :any)

    params, rest = parse(%w[a b c d e f], args)

    expect(params[:foo]).to eq(%w[a b])
    expect(params[:bar]).to eq("c")
    expect(params[:baz]).to eq(%w[d e f])
    expect(rest).to eq([])
  end

  it "consumes only arguments for :any arity and collects remaining" do
    params, rest = parse(%w[-b a k=1 b ENV_VAR=dev --bar c], arg(:foo, arity: "*"))

    expect(params[:foo]).to eq(%w[a b c])
    expect(rest).to eq(%w[-b k=1 ENV_VAR=dev --bar])
  end

  it "consumes only arguments for specified arity" do
    params, rest = parse(%w[-b a k=1 b ENV_VAR=dev --bar c], arg(:foo, arity: 3))

    expect(params[:foo]).to eq(%w[a b c])
    expect(rest).to eq(%w[-b k=1 ENV_VAR=dev --bar])
  end

  context "when :default" do
    it "parses no arguments and has default value" do
      params, rest = parse([], arg(:foo, arity: 2, default: %w[a b]))

      expect(params[:foo]).to eq(%w[a b])
      expect(rest).to eq([])
    end

    it "parses no arguments and has proc default" do
      params, rest = parse([], arg(:foo, arity: 2, default: -> { %w[a b] }))

      expect(params[:foo]).to eq(%w[a b])
      expect(rest).to eq([])
    end
  end

  context "when :convert" do
    it "converts an argument to a list" do
      params, rest = parse(%w[a,b,c], arg(:foo, convert: :list))

      expect(params[:foo]).to eq(%w[a b c])
      expect(rest).to eq([])
    end
  end
end
