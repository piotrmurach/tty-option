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

  it "parses keywords with custom names" do
    keywords = []
    keywords << keyword(:foo, variable: "fum-var")
    keywords << keyword(:bar, variable: "qux-var")

    params, rest = parse(%w[fum-var=a qux-var=b -wrong=c], keywords)

    expect(params[:foo]).to eq("a")
    expect(params[:bar]).to eq("b")
    expect(rest).to eq(%w[-wrong=c])
  end

  it "converts keyword param names to parsed variables" do
    keywords = []
    keywords << keyword(:foo_var)
    keywords << keyword(:bar_var)

    params, rest = parse(%w[foo-var=a bar-var=b -wrong=c], keywords)

    expect(params[:foo_var]).to eq("a")
    expect(params[:bar_var]).to eq("b")
    expect(rest).to eq(%w[-wrong=c])
  end

  it "raises if required keyword isn't present" do
    expect {
      parse(%w[], keyword(:foo, required: true), raise_on_parse_error: true)
    }.to raise_error(TTY::Option::MissingParameter,
                     "need to provide 'foo' keyword")
  end

  it "collects all keywords missing errors" do
    keywords = []
    keywords << keyword(:foo, required: true)
    keywords << keyword(:bar, required: true)

    params, rest, errors = parse(%w[], keywords)

    expect(params[:foo]).to eq(nil)
    expect(params[:bar]).to eq(nil)
    expect(rest).to eq([])
    expect(errors.map(&:message)).to eq([
      "need to provide 'foo' keyword",
      "need to provide 'bar' keyword"
    ])
  end

  it "parses unrecognized keywords and collects error" do
    keywords = []
    keywords << keyword(:foo)
    params, rest, errors = parse(%w[foo=a unknown=b], keywords)

    expect(params[:foo]).to eq("a")
    expect(rest).to eq([])
    expect(errors.map(&:message)).to eq(["invalid keyword unknown=b"])
  end

  it "parses unrecognized keywords and doesn't check invalid parameter" do
    keywords = []
    keywords << keyword(:foo)
    params, rest, errors = parse(%w[foo=a unknown=b], keywords,
                                 check_invalid_params: false)
    expect(params[:foo]).to eq("a")
    expect(rest).to eq(["unknown=b"])
    expect(errors).to eq([])
  end

  it "collects all remaining parameters" do
    keywords = []
    keywords << keyword(:foo)
    keywords << keyword(:bar)

    argv = %w[-u arg1 foo=a --unknown arg2 FOO_ENV=b bar=c other=d -b f]
    params, rest, errors = parse(argv, keywords, check_invalid_params: false)

    expect(params[:foo]).to eq("a")
    expect(params[:bar]).to eq("c")
    expect(rest).to eq(%w[-u arg1 --unknown arg2 FOO_ENV=b other=d -b f])
    expect(errors).to eq([])
  end

  context "when multiple times" do
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

    it "parses short flag with required argument many times and keeps all" do
      keyword = keyword(:foo, convert: :int_list, arity: -2)
      params, rest = parse(%w[foo=1 foo=2 foo=3], keyword)

      expect(params[:foo]).to eq([1, 2, 3])
      expect(rest).to eq([])
    end

    it "doesn't find enough keywords to match specific arity" do
      expect {
        parse(%w[foo=1], keyword(:foo, arity: 2), raise_on_parse_error: true)
      }.to raise_error(TTY::Option::InvalidArity,
                      "expected keyword :foo to appear 2 times but " \
                      "appeared 1 time")
    end

    it "parses minimum number of keywords to satisfy at least arity" do
      params, = parse(%w[foo=1 foo=2 foo=3], keyword(:foo, arity: -3))

      expect(params[:foo]).to eq(%w[1 2 3])
    end

    it "doesn't find enough keywords to match at least arity" do
      expect {
        parse(%w[foo=1], keyword(:foo, arity: -3), raise_on_parse_error: true)
      }.to raise_error(TTY::Option::InvalidArity,
                      "expected keyword :foo to appear at least 2 times but " \
                      "appeared 1 time")
    end

    it "doesn't find any keywords to match at least arity" do
      expect {
        parse([], keyword(:foo, arity: -2), raise_on_parse_error: true)
      }.to raise_error(TTY::Option::InvalidArity,
                       "expected keyword :foo to appear at least 1 time but " \
                       "appeared 0 times")
    end

    it "parses multiple keywords" do
      params, rest = parse(%w[foo=1 foo=2 foo=3], keyword(:foo, arity: :any))

      expect(params[:foo]).to eq(%w[1 2 3])
      expect(rest).to eq([])
    end

    it "collects all arity errors" do
      keywords = []
      keywords << keyword(:foo, arity: 2)
      keywords << keyword(:bar, arity: -3)

      params, rest, errors = parse(%w[foo=1 bar=2], keywords)

      expect(params[:foo]).to eq(["1"])
      expect(params[:bar]).to eq(["2"])
      expect(rest).to eq([])
      expect(errors.map(&:message)).to eq([
        "expected keyword :foo to appear 2 times but appeared 1 time",
        "expected keyword :bar to appear at least 2 times but appeared 1 time"
      ])
    end
  end

  context "when default" do
    it "parses last keyword without arity" do
      params, rest = parse(%w[], keyword(:foo, default: "1"))

      expect(params[:foo]).to eq("1")
      expect(rest).to eq([])
    end
  end

  context "when a list argument" do
    it "parses a comma delimited argument as a list" do
      params, rest = parse(%w[foo=a,b,c], keyword(:foo, convert: :list))

      expect(params[:foo]).to eq(%w[a b c])
      expect(rest).to eq([])
    end

    it "parses space delimited arguments as a list" do
      params, rest = parse(%w[foo=a b c], keyword(:foo, convert: :list))

      expect(params[:foo]).to eq(%w[a b c])
      expect(rest).to eq([])
    end

    it "parsers keywords with list arguments correctly" do
      keywords = []
      keywords << keyword(:foo, convert: :list)
      keywords << keyword(:bar, convert: :list)

      params, rest = parse(%w[foo=a b bar=c d e --baz], keywords)

      expect(params[:foo]).to eq(%w[a b])
      expect(params[:bar]).to eq(%w[c d e])
      expect(rest).to eq(%w[--baz])
    end
  end

  context "when a map argument" do
    it "parses a space delimited arguments as a map" do
      params, rest = parse(%w[foo=a:1 b:2 c:3], keyword(:foo, convert: :map))

      expect(params[:foo]).to eq({a:"1", b:"2", c:"3"})
      expect(rest).to eq([])
    end

    it "parses maps from different keywords" do
      keywords = []
      keywords << keyword(:foo, convert: :int_map)
      keywords << keyword(:bar, convert: :int_map)

      params, rest = parse(%w[foo=a:1 b:2 c:3 bar=x:1 y:2], keywords)

      expect(params[:foo]).to eq({a:1, b:2, c:3})
      expect(params[:bar]).to eq({x:1, y:2})
      expect(rest).to eq([])
    end

    it "combines multiple keywords with map arguments" do
      keywords = []
      keywords << keyword(:foo, convert: :int_map, arity: :any)

      params, rest = parse(%w[foo=a:1 b:2 foo=c:3 d:4], keywords)

      expect(params[:foo]).to eq({a:1, b:2, c:3, d: 4})
      expect(rest).to eq([])
    end
  end
end
