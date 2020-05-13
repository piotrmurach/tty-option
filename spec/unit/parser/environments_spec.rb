# frozen_string_literal: true

RSpec.describe TTY::Option::Parser::Environments do
  def env(name, **settings)
    TTY::Option::Parameter::Environment.create(name, **settings)
  end

  def parse(argv, env, envs, **config)
    parser = described_class.new(Array(envs), **config)
    parser.parse(argv, env)
  end

  it "doesn't parse any env vars" do
    params, rest = parse(%w[], {}, env(:foo))

    expect(params[:foo]).to eq(nil)
    expect(rest).to eq([])
  end

  it "parses an env var matching param name" do
    params, rest = parse(%w[FOO=bar], {}, env(:foo))

    expect(params[:foo]).to eq("bar")
    expect(rest).to eq([])
  end

  it "parses an env var with custom name" do
    envs = []
    envs << env(:foo, variable: "FOO_BAR")
    params, rest = parse(%w[FOO_BAR=baz], {}, envs)

    expect(params[:foo]).to eq("baz")
    expect(rest).to eq([])
  end

  it "parses different env vars" do
    envs = []
    envs << env(:foo, variable: "FOO_ENV")
    envs << env(:bar, variable: "BAR_ENV" )
    envs << env(:baz)
    params, rest = parse(%w[FOO_ENV=a BAZ=b BAR_ENV=c], {}, envs)

    expect(params[:foo]).to eq("a")
    expect(params[:bar]).to eq("c")
    expect(params[:baz]).to eq("b")
    expect(rest).to eq([])
  end

  it "parses an env var from the env hash" do
    params, rest = parse(%w[], {"FOO" => "bar"}, env(:foo))

    expect(params[:foo]).to eq("bar")
    expect(rest).to eq([])
  end

  it "doesn't parse required env var" do
    expect {
      parse([], {}, env(:foo, required: true), raise_on_parse_error: true)
    }.to raise_error(TTY::Option::MissingParameter,
                    "need to provide 'FOO' environment")
  end

  it "checks for required env var in env hash" do
    expect {
      parse([], {"FOO" => "bar"}, env(:foo, required: true))
    }.not_to raise_error
  end

  it "accumulates errors for required env vars when missing" do
    envs = []
    envs << env(:foo, required: true)
    envs << env(:bar, required: true)
    envs << env(:baz, optional: true)

    params, rest, errors = parse([], {}, envs)

    expect(params[:foo]).to eq(nil)
    expect(params[:bar]).to eq(nil)
    expect(params[:baz]).to eq(nil)
    expect(rest).to eq([])
    expect(errors.map(&:message)).to eq([
      "need to provide 'FOO' environment",
      "need to provide 'BAR' environment"
    ])
  end

  it "parses unrecognized env vars and collects error" do
    envs = []
    envs << env(:foo, variable: "FOO_ENV")
    params, rest, errors = parse(%w[FOO_ENV=a WRONG=d], {}, envs)

    expect(params[:foo]).to eq("a")
    expect(rest).to eq([])
    expect(errors.map(&:message)).to eq(["invalid environment WRONG=d"])
  end

  it "parses unrecognized env vars and doesn't check invalid parameter" do
    envs = []
    envs << env(:foo, variable: "FOO_ENV")
    params, rest, errors = parse(%w[FOO_ENV=a WRONG=d], {}, envs,
                                 check_invalid_params: false)

    expect(params[:foo]).to eq("a")
    expect(rest).to eq(["WRONG=d"])
    expect(errors).to eq([])
  end

  it "collects all remaining parameters" do
    envs = []
    envs << env(:foo)
    envs << env(:bar)

    argv = %w[-u arg1 FOO=a --unknown arg2 UNKNOWN=b BAR=c -b d]
    params, rest, errors = parse(argv, {}, envs, check_invalid_params: false)

    expect(params[:foo]).to eq("a")
    expect(params[:bar]).to eq("c")
    expect(rest).to eq(%w[-u arg1 --unknown arg2 UNKNOWN=b -b d])
    expect(errors).to eq([])
  end

  context "when multiple times" do
    it "parses an env var matching param name with exact arity" do
      params, rest = parse(%w[FOO=a FOO=b FOO=c], {}, env(:foo, arity: 2))

      expect(params[:foo]).to eq(%w[a b])
      expect(rest).to eq(%w[FOO=c])
    end

    it "parses an env var matching param name with any arity" do
      params, rest = parse(%w[FOO=a FOO=b FOO=c], {}, env(:foo, arity: :any))

      expect(params[:foo]).to eq(%w[a b c])
      expect(rest).to eq(%w[])
    end

    it "parses env vars from command line and hash for any arity" do
      params, rest = parse(%w[FOO=a FOO=c], {"FOO" => "b"}, env(:foo, arity: :any))

      expect(params[:foo]).to eq(%w[a c b])
      expect(rest).to eq([])
    end

    it "parses env var many times and keeps all" do
      envs = []
      envs << env(:foo, convert: :int_list, arity: -2)
      params, rest = parse(%w[FOO=1 FOO=2 FOO=3], {}, envs)

      expect(params[:foo]).to eq([1, 2, 3])
      expect(rest).to eq([])
    end

    it "doesn't find enough env vars to match specific arity" do
      expect {
        parse(%w[FOO=a], {}, env(:foo, arity: 2), raise_on_parse_error: true)
      }.to raise_error(TTY::Option::InvalidArity,
                      "expected environment 'FOO' to appear 2 times but " \
                      "appeared 1 time")
    end

    it "parses minimum number of env vars to satisfy at least arity" do
      params, = parse(%w[FOO=a FOO=b], {"FOO" => "c"}, env(:foo, arity: -3))

      expect(params[:foo]).to eq(%w[a b c])
    end

    it "doesn't find enough env vars to match at least arity" do
      expect {
        parse(%w[FOO=a], {}, env(:foo, arity: -3), raise_on_parse_error: true)
      }.to raise_error(TTY::Option::InvalidArity,
                      "expected environment 'FOO' to appear at least 2 times but " \
                      "appeared 1 time")
    end

    it "doesn't find any env vars to match at least arity" do
      expect {
        parse([], {}, env(:foo, arity: -2), raise_on_parse_error: true)
      }.to raise_error(TTY::Option::InvalidArity,
                       "expected environment 'FOO' to appear at least 1 time but " \
                       "appeared 0 times")
    end

    it "collects all arity errors" do
      envs = []
      envs << env(:foo, arity: 2)
      envs << env(:bar, arity: -3)

      params, rest, errors = parse(%w[FOO=1 BAR=2], {}, envs)

      expect(params[:foo]).to eq(["1"])
      expect(params[:bar]).to eq(["2"])
      expect(rest).to eq([])
      expect(errors.map(&:message)).to eq([
        "expected environment 'FOO' to appear 2 times but appeared 1 time",
        "expected environment 'BAR' to appear at least 2 times but appeared 1 time"
      ])
    end
  end

  context "when default" do
    it "defaults an env var" do
      params, rest = parse([], {}, env(:foo, default: "bar"))

      expect(params[:foo]).to eq("bar")
      expect(rest).to eq([])
    end

    it "defaults an env var to proc result" do
      params, rest = parse([], {}, env(:foo, default: -> { "bar" }))

      expect(params[:foo]).to eq("bar")
      expect(rest).to eq([])
    end
  end

  context "when a list argument" do
    it "converts an argument to a list" do
      params, rest = parse(%w[FOO=a,b,c], {}, env(:foo, convert: :list))

      expect(params[:foo]).to eq(%w[a b c])
      expect(rest).to eq([])
    end

    it "parses space delimited arguments as a list" do
      params, rest = parse(%w[FOO=a b c], {}, env(:foo, convert: :list))

      expect(params[:foo]).to eq(%w[a b c])
      expect(rest).to eq([])
    end

    it "parsers envs with list arguments correctly" do
      envs = []
      envs << env(:foo, convert: :list)
      envs << env(:bar, convert: :list)

      params, rest = parse(%w[FOO=a b BAR=c d e --baz], {}, envs)

      expect(params[:foo]).to eq(%w[a b])
      expect(params[:bar]).to eq(%w[c d e])
      expect(rest).to eq(%w[--baz])
    end
  end

  context "when a map argument" do
    it "parses a space delimited arguments as a map" do
      params, rest = parse(%w[FOO=a:1 b:2 c:3], {}, env(:foo, convert: :map))

      expect(params[:foo]).to eq({a:"1", b:"2", c:"3"})
      expect(rest).to eq([])
    end

    it "parses maps from different envs" do
      envs = []
      envs << env(:foo, convert: :int_map)
      envs << env(:bar, convert: :int_map)

      params, rest = parse(%w[FOO=a:1 b:2 c:3 BAR=x:1 y:2], {}, envs)

      expect(params[:foo]).to eq({a:1, b:2, c:3})
      expect(params[:bar]).to eq({x:1, y:2})
      expect(rest).to eq([])
    end

    it "combines multiple envs with map arguments" do
      envs = []
      envs << env(:foo, convert: :int_map, arity: :any)

      params, rest = parse(%w[FOO=a:1 b:2 FOO=c:3 d:4], {}, envs)

      expect(params[:foo]).to eq({a:1, b:2, c:3, d: 4})
      expect(rest).to eq([])
    end
  end
end
