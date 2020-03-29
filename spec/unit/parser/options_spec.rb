# frozen_string_literal: true

RSpec.describe TTY::Option::Parser::Options do
  def option(name, **settings)
    TTY::Option::Parameter::Option.create(name, **settings)
  end

  def parse(argv, options, **config)
    parser = TTY::Option::Parser::Options.new(Array(options), **config)
    parser.parse(argv)
  end

  it "parses short flag" do
    params, = parse(%w[-f], option(:foo, short: "-f"))

    expect(params[:foo]).to eq(true)
  end

  it "parses required argument for a short option" do
    params, = parse(%w[-f bar], option(:foo, short: "-f string"))

    expect(params[:foo]).to eq("bar")
  end

  it "parses short option next to required argument and defined together" do
    params, = parse(%w[-ff], option(:foo, short: "-fstring"))

    expect(params[:foo]).to eq("f")
  end

  it "parses short option next to required argument but defined separate" do
    params, = parse(%w[-fbar], option(:foo, short: "-f string"))

    expect(params[:foo]).to eq("bar")
  end

  it "parses short option separate from required argument but defined together" do
    params, = parse(%w[-f bar], option(:foo, short: "-fstring"))

    expect(params[:foo]).to eq("bar")
  end

  it "raises if short option without argument and defined seprate and required" do
    expect {
      parse(%w[-f], option(:foo, short: "-f string"))
    }.to raise_error(TTY::Option::MissingArgument, "option -f requires an argument")
  end

  it "raises if short option without argument but defined together and required" do
    expect {
      parse(%w[-f], option(:foo, short: "-fstring"))
    }.to raise_error(TTY::Option::MissingArgument, "option -f requires an argument")
  end

  it "parses short option with argument that looks like short option" do
    options = []
    options << option(:foo, short: "-f string")
    options << option(:qux, short: "-q")

    params, = parse(%w[-f -b -q], options)

    expect(params[:foo]).to eq("-b")
    expect(params[:qux]).to eq(true)
  end

  it "parses short option with an argument when a seprate optional arg defined" do
    params, = parse(%w[-f bar], option(:foo, short: "-f [string]"))

    expect(params[:foo]).to eq("bar")
  end

  it "parses short option without argument with a glued optional arg defined" do
    params, = parse(%w[-f], option(:foo, short: "-f[string]"))

    expect(params[:foo]).to eq(nil)
  end

  it "parses short option with an optional argument defined separate" do
    params, = parse(%w[-f], option(:foo, short: "-f [string]"))

    expect(params[:foo]).to eq(nil)
  end

  it "raises if short option isn't defined" do
    expect {
      parse(%w[-b], option(:foo, short: "-f"))
    }.to raise_error(TTY::Option::InvalidOption, "invalid option -b")
  end

  it "collects errors when :rais_if_missing is false" do
    options = []
    options << option(:foo, short: "-f")
    params, rest, errors = parse(%w[-b], options, raise_if_missing: false)

    expect(params[:foo]).to eq(nil)
    expect(rest).to eq([])
    expect(errors).to eq({invalid: "invalid option -b"})
  end

  it "parses compacted flags" do
    options = []
    options << option(:foo, short: "-f")
    options << option(:bar, short: "-b")
    options << option(:qux, short: "-q")

    params, rest = parse(%w[-fbq], options)

    expect(params[:foo]).to eq(true)
    expect(params[:bar]).to eq(true)
    expect(params[:qux]).to eq(true)
    expect(rest).to eq([])
  end

  it "parses compacted flags with an argument" do
    options = []
    options << option(:foo, short: "-f")
    options << option(:bar, short: "-b")
    options << option(:qux, short: "-q int")

    params, rest = parse(%w[-fbq 12], options)

    expect(params[:foo]).to eq(true)
    expect(params[:bar]).to eq(true)
    expect(params[:qux]).to eq("12")
    expect(rest).to eq([])
  end

  it "skips non-options arguments" do
    options = []
    options << option(:foo, short: "-f")

    params, rest = parse(%w[arg1 arg2 -f arg3], options)

    expect(params[:foo]).to eq(true)
    expect(rest).to eq(%w[arg1 arg2 arg3])
  end

  it "parses long flag" do
    params, = parse(%w[--foo], option(:foo, long: "--foo"))

    expect(params[:foo]).to eq(true)
  end

  it "parses long option with a separate argument defined separate" do
    params, = parse(%w[--foo bar], option(:foo, long: "--foo string"))

    expect(params[:foo]).to eq("bar")
  end

  it "parses long option separted with = from required argument" do
    params, = parse(%w[--foo=bar], option(:foo, long: "--foo string"))

    expect(params[:foo]).to eq("bar")
  end

  it "parses long option separted with = from argument and defined with =" do
    params, = parse(%w[--foo=bar], option(:foo, long: "--foo=string"))

    expect(params[:foo]).to eq("bar")
  end

  it "parses long option with multiple arguments as a single value" do
    params, = parse(%w[--foo bar\ baz], option(:foo, long: "--foo string"))

    expect(params[:foo]).to eq("bar baz")
  end

  it "raises if long option with no argument" do
    expect {
      parse(%w[--foo], option(:foo, long: "--foo string"))
    }.to raise_error(TTY::Option::MissingArgument,
                     "option --foo requires an argument")
  end

  it "parses long option with an optional argument defined together" do
    params, = parse(%w[--foo], option(:foo, long: "--foo[string]"))

    expect(params[:foo]).to eq(nil)
  end

  it "parses long option with an optional argument defined separate" do
    params, = parse(%w[--foo], option(:foo, long: "--foo [string]"))

    expect(params[:foo]).to eq(nil)
  end

  it "parses long option with an argument when an optional arg defined separate" do
    params, = parse(%w[--foo bar], option(:foo, long: "--foo [string]"))

    expect(params[:foo]).to eq("bar")
  end

  it "parses long option with an argument when an optional arg defined together" do
    params, = parse(%w[--foo bar], option(:foo, long: "--foo[string]"))

    expect(params[:foo]).to eq("bar")
  end

  it "parses long option with a glued argument when an optional arg defined separate" do
    params, = parse(%w[--foobar], option(:foo, long: "--foo [string]"))

    expect(params[:foo]).to eq("bar")
  end

  it "raises if long option isn't defined" do
    expect {
      parse(%w[--foo --bar], option(:foo, long: "--foo"))
    }.to raise_error(TTY::Option::InvalidOption, "invalid option --bar")
  end

  it "raises if long option isn't defined" do
    options = []
    options << option(:foo, long: "--foobar")
    options << option(:foo, long: "--foobaz")

    expect {
      parse(%w[--foob ], options)
    }.to raise_error(TTY::Option::AmbiguousOption, "option --foob is ambiguous")
  end

  it "consumes non-option arguments" do
    options = []
    options << option(:foo, long: "--foo string")
    options << option(:bar, short: "-b")

    params, rest = parse(%w[arg1 --foo baz arg2 --bar arg3 -b], options)

    expect(params[:foo]).to eq("baz")
    expect(params[:bar]).to eq(true)
    expect(rest).to eq(%w[arg1 arg2 arg3])
  end

  it "parses option-like values and ignores arguments looking like options" do
    options = []
    options << option(:foo, short: "-f", long: "--foo string")

    params, rest = parse(%w[some---arg --foo --some--weird---value], options)

    expect(params[:foo]).to eq("--some--weird---value")
    expect(rest).to eq(%w[some---arg])
  end

  context "when no arguments" do
    it "defines no flags and returns empty hash" do
      params, rest = parse([], [])

      expect(params).to eq({})
      expect(rest).to eq([])
    end
  end

  context "when default" do
    it "parses option with a default when no arguments provided" do
      options = []
      options << option(:foo, short: "-f digit", default: "12")

      params, = parse(%w[], options)

      expect(params[:foo]).to eq("12")
    end

    it "parses option with a default proc value when no arguments provided" do
      options = []
      options << option(:foo, short: "-f digit", default: -> { "12" })

      params, = parse(%w[], options)

      expect(params[:foo]).to eq("12")
    end
  end

  context "when convert" do
    it "parses short option with a required argument and converts to int" do
      options = []
      options << option(:foo, short: "-f digit", convert: :int)

      params, = parse(%w[-f 12], options)

      expect(params[:foo]).to eq(12)
    end
  end

  context "when multiple times" do
    it "parses short flag many times" do
      params, rest = parse(%w[-f -f -f], option(:foo, short: "-f"))

      expect(params[:foo]).to eq(true)
      expect(rest).to eq([])
    end

    it "parses short flag with required argument and keeps the last argument" do
      params, rest = parse(%w[-f 1 -f 2 -f 3], option(:foo, short: "-f int"))

      expect(params[:foo]).to eq("3")
      expect(rest).to eq([])
    end

    it "parses long flag with required argument and keeps the last argument" do
      params, rest = parse(%w[--f 1 --f 2 --f 3], option(:foo, long: "--f int"))

      expect(params[:foo]).to eq("3")
      expect(rest).to eq([])
    end
  end
end
