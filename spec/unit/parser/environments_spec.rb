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

  context "when :arity" do
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
  end

  context "when :default" do
    it "defaults an env var" do
      params, rest = parse([], {}, env(:foo, default: "bar"))

      expect(params[:foo]).to eq("bar")
      expect(rest).to eq([])
    end

    it "defaults an env var" do
      params, rest = parse([], {}, env(:foo, default: -> { "bar" }))

      expect(params[:foo]).to eq("bar")
      expect(rest).to eq([])
    end
  end
end
