# frozen_string_literal: true

RSpec.describe TTY::Option::Parser::Keywords do
  def keyword(name, **settings)
    TTY::Option::Parameter::Keyword.create(name, **settings)
  end

  def parse(argv, kwargs, **config)
    parser = described_class.new(Array(kwargs), **config)
    parser.parse(argv)
  end

  it "parses a single keyword" do
    params, rest = parse(%w[foo=1], keyword(:foo))

    expect(params[:foo]).to eq("1")
    expect(rest).to eq([])
  end

  it "parses a few different keywords" do
    keywords = []
    keywords << keyword(:foo)
    keywords << keyword(:bar)
    keywords << keyword(:baz)
    params, rest = parse(%w[foo=1 bar=a baz=false], keywords)

    expect(params[:foo]).to eq("1")
    expect(params[:bar]).to eq("a")
    expect(params[:baz]).to eq("false")
    expect(rest).to eq([])
  end

  it "consumes only keywords and collects remaining" do
    keywords = []
    keywords << keyword(:foo, arity: "*")
    params, rest = parse(%w[-b foo=1 b ENV_VAR=dev foo=2 --bar], keywords)

    expect(params[:foo]).to eq(%w[1 2])
    expect(rest).to eq(%w[-b b ENV_VAR=dev --bar])
  end

  it "raises if required keyword isn't present" do
    expect {
      parse(%w[], keyword(:foo, required: true))
    }.to raise_error(TTY::Option::MissingParameter,
                     "need to provide 'foo' keyword")
  end

  it "collects all keywords missing errors" do
    keywords = []
    keywords << keyword(:foo, required: true)
    keywords << keyword(:bar, required: true)

    params, rest, errors = parse(%w[], keywords, raise_if_missing: false)

    expect(params[:foo]).to eq(nil)
    expect(params[:bar]).to eq(nil)
    expect(rest).to eq([])
    expect(errors[:foo]).to eq({missing_parameter: "need to provide 'foo' keyword"})
    expect(errors[:bar]).to eq({missing_parameter: "need to provide 'bar' keyword"})
  end

  context ":arity" do
    it "parses last keyword without arity" do
      params, rest = parse(%w[foo=1 foo=2], keyword(:foo))

      expect(params[:foo]).to eq("2")
      expect(rest).to eq([])
    end

    it "parses exactly 2 keywords" do
      params, rest = parse(%w[foo=1 foo=2 foo=3], keyword(:foo, arity: 2))

      expect(params[:foo]).to eq(%w[1 2])
      expect(rest).to eq(["foo=3"])
    end

    it "parses multiple keywords" do
      params, rest = parse(%w[foo=1 foo=2 foo=3], keyword(:foo, arity: :any))

      expect(params[:foo]).to eq(%w[1 2 3])
      expect(rest).to eq([])
    end
  end

  context ":default" do
    it "parses last keyword without arity" do
      params, rest = parse(%w[], keyword(:foo, default: "1"))

      expect(params[:foo]).to eq("1")
      expect(rest).to eq([])
    end
  end

  context "when :convert" do
    it "converts an argument to a list" do
      params, rest = parse(%w[foo=a,b,c], keyword(:foo, convert: :list))

      expect(params[:foo]).to eq(%w[a b c])
      expect(rest).to eq([])
    end
  end
end
