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

  it "doesn't parse short flag" do
    params, = parse(%w[], option(:foo, short: "-f"))

    expect(params[:foo]).to eq(false)
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

  it "raises if short option isn't defined" do
    params, rest, errors = parse(%w[-b], option(:foo, short: "-f"),
                                  check_invalid_options: false)

    expect(params[:foo]).to eq(false)
    expect(rest).to eq([])
    expect(errors).to eq({})
  end

  it "collects errors when :rais_if_missing is false" do
    options = []
    options << option(:foo, short: "-f")
    params, rest, errors = parse(%w[-b], options, raise_if_missing: false)

    expect(params[:foo]).to eq(false)
    expect(rest).to eq([])
    expect(errors[:messages]).to eq([{invalid_option: "invalid option -b"}])
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

  it "parses long option with empty argument and defined together with =" do
    params,  = parse(%w[--foo=], option(:foo, long: "--foo=string"))

    expect(params[:foo]).to eq("")
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

  it "raises if option isn't present" do
    expect {
      parse(%w[], option(:foo, long: "--foo string", required: true))
    }.to raise_error(TTY::Option::MissingParameter,
                     "need to provide '--foo' option")
  end

  it "collects all options missing errors" do
    options = []
    options << option(:foo, long: "--foo string", required: true)
    options << option(:bar, short: "-b string", required: true)

    params, rest, errors = parse(%w[], options, raise_if_missing: false)

    expect(params[:foo]).to eq(nil)
    expect(params[:bar]).to eq(nil)
    expect(rest).to eq([])
    expect(errors[:foo]).to eq({missing_parameter: "need to provide '--foo' option"})
    expect(errors[:bar]).to eq({missing_parameter: "need to provide '-b' option"})
  end

  context "when no arguments" do
    it "defines no flags and returns empty hash" do
      params, rest = parse([], [])

      expect(params).to eq({})
      expect(rest).to eq([])
    end

    it "parses no short or long options" do
      options = []
      options << option(:foo, short: "-f", long: "--foo")
      options << option(:bar, short: "-b", long: "--bar")

      params, = parse(%w[], options)

      expect(params[:foo]).to eq(false)
      expect(params[:bar]).to eq(false)
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

    it "parses short flag with required argument many times and keeps only two" do
      params, rest = parse(%w[-f 1 -f 2 -f 3], option(:foo, short: "-f int", arity: 2))

      expect(params[:foo]).to eq(%w[1 2])
      expect(rest).to eq(%w[-f 3])
    end

    it "parses short flag with required argument many times and keeps all" do
      opt = option(:foo, short: "-f list", convert: :int_list, arity: -2)
      params, rest = parse(%w[-f 1 2 3], opt)

      expect(params[:foo]).to eq([1, 2, 3])
      expect(rest).to eq([])
    end

    it "parses short flag with required argument many times and keeps only two" do
      opt = option(:foo, short: "-f int", convert: :int_map, arity: 2)
      params, rest = parse(%w[-f a:1 -f b:2 -f c:3], opt)

      expect(params[:foo]).to eq({a: 1, b: 2})
      expect(rest).to eq(["-f", {c: 3}])
    end

    it "parses short flag with required argument many times and keeps all" do
      params, rest = parse(%w[-f 1 -f 2 -f 3], option(:foo, short: "-f int", arity: :any))

      expect(params[:foo]).to eq(%w[1 2 3])
      expect(rest).to eq([])
    end

    it "fails to match required arity for short flag" do
      expect {
        parse(%w[-f 1], option(:foo, short: "-f int", arity: 2))
      }.to raise_error(TTY::Option::InvalidArity,
                       "expected option :foo to appear 2 times but appeared 1 time")
    end

    it "doesn't find enough options to match at least arity for short flag" do
      expect {
        parse(%w[-f 1], option(:foo, short: "-f int", arity: -3))
      }.to raise_error(TTY::Option::InvalidArity,
                       "expected option :foo to appear at least 2 times but " \
                       "appeared 1 time")
    end

    it "doesn't find any options to match at least arity for short flag" do
      expect {
        parse([], option(:foo, short: "-f int", arity: -2))
      }.to raise_error(TTY::Option::InvalidArity,
                       "expected option :foo to appear at least 1 time but " \
                       "appeared 0 times")
    end

    it "collects all arity errors" do
      options = []
      options << option(:foo, short: "-f int", arity: 2)
      options << option(:bar, short: "-b int", arity: -3)

      params, rest, errors = parse(%w[-f 1 -b 2], options, raise_if_missing: false)

      expect(params[:foo]).to eq(["1"])
      expect(params[:bar]).to eq(["2"])
      expect(rest).to eq([])
      expect(errors[:foo]).to eq({invalid_arity: "expected option :foo to appear 2 times but appeared 1 time"})
      expect(errors[:bar]).to eq({invalid_arity: "expected option :bar to appear at least 2 times but appeared 1 time"})
    end

    it "parses long flag with required argument and keeps the last argument" do
      params, rest = parse(%w[--f 1 --f 2 --f 3], option(:foo, long: "--f int"))

      expect(params[:foo]).to eq("3")
      expect(rest).to eq([])
    end

    it "parses long flags with required argument and keeps all" do
      params, rest = parse(%w[--f 1 --f 2 --f 3], option(:foo, long: "--f int", arity: -2))

      expect(params[:foo]).to eq(%w[1 2 3])
      expect(rest).to eq([])
    end
  end

  context "when list argument" do
    it "parses short option with a list argument" do
      options = []
      options << option(:foo, short: "-f list", convert: :list)
      options << option(:bar, short: "-b")

      params, = parse(%w[-f a b c -b], options)

      expect(params[:foo]).to eq(%w[a b c])
    end

    it "parses compacted short options with a separate list argument" do
      options = []
      options << option(:foo, short: "-f")
      options << option(:bar, short: "-b")
      options << option(:qux, short: "-q list", convert: :list)

      params, = parse(%w[-fbq a b c], options)

      expect(params[:foo]).to eq(true)
      expect(params[:bar]).to eq(true)
      expect(params[:qux]).to eq(%w[a b c])
    end

    it "parses compacted short options with a list argument glued together" do
      options = []
      options << option(:foo, short: "-f")
      options << option(:bar, short: "-b")
      options << option(:qux, short: "-q list", convert: :list)

      params, = parse(%w[-fbqa b c], options)

      expect(params[:foo]).to eq(true)
      expect(params[:bar]).to eq(true)
      expect(params[:qux]).to eq(%w[a b c])
    end

    it "parses short option with an optional list argument" do
      options = []
      options << option(:foo, short: "-f [list]", convert: :list)
      options << option(:bar, short: "-b")

      params, rest = parse(%w[-f a b c -b], options)

      expect(params[:foo]).to eq(%w[a b c])
      expect(params[:bar]).to eq(true)
      expect(rest).to eq([])
    end

    it "parses short option with a list argument provided together" do
      options = []
      options << option(:foo, short: "-f list", convert: :list)

      params, = parse(%w[-fa b c], options)

      expect(params[:foo]).to eq(%w[a b c])
    end

    it "parses short option with an optional list argument provided together" do
      options = []
      options << option(:foo, short: "-f [list]", convert: :list)

      params, = parse(%w[-fa b c], options)

      expect(params[:foo]).to eq(%w[a b c])
    end

    it "parses short option with a list comma delimited argument" do
      options = []
      options << option(:foo, short: "-f list", convert: :list)

      params, = parse(%w[-f a,b,c], options)

      expect(params[:foo]).to eq(%w[a b c])
    end

    it "parses long option with a list argument and assigment symbol" do
      options = []
      options << option(:foo, long: "--foo=list", convert: :list)

      params, = parse(%w[--foo=a b c], options)

      expect(params[:foo]).to eq(%w[a b c])
    end

    it "parses long option with an optional list argument" do
      options = []
      options << option(:foo, long: "--foo [list]", convert: :list)

      params, = parse(%w[--foo=a b c], options)

      expect(params[:foo]).to eq(%w[a b c])
    end

    it "parses long option with list argument and cast" do
      options = []
      options << option(:foo, long: "--foo list", convert: :list)
      options << option(:bar, long: "--bar")

      params, rest = parse(%w[--foo a b c --bar], options)

      expect(params[:foo]).to eq(%w[a b c])
      expect(params[:bar]).to eq(true)
      expect(rest).to eq([])
    end

    it "parses long option with optional list argument and cast" do
      options = []
      options << option(:foo, long: "--foo [list]", convert: :list)
      options << option(:bar, long: "--bar")

      params, rest = parse(%w[--foo a b c --bar], options)

      expect(params[:foo]).to eq(%w[a b c])
      expect(rest).to eq([])
    end

    it "doesn't mix with other long options" do
      options = []
      options << option(:foo, long: "--foo list", convert: :list)
      options << option(:bar, long: "--bar list", convert: :list)

      params, rest = parse(%w[--foo a b c --bar x y], options)

      expect(params[:foo]).to eq(%w[a b c])
      expect(params[:bar]).to eq(%w[x y])
      expect(rest).to eq([])
    end

    it "combines multiple options with list arguments" do
      options = []
      options << option(:foo, short: "-f list", convert: :list, arity: :any)

      params, rest = parse(%w[-f a b -f c d], options)

      expect(params[:foo]).to eq(%w[a b c d])
      expect(rest).to eq([])
    end

    it "parses option with a conversion" do
      options = []
      options << option(:foo, long: "--foo=list", convert: :list)

      params, = parse(%w[--foo=,,], options)

      expect(params[:foo]).to eq([])
    end
  end

  context "when map argument" do
    it "parses short option with a map argument" do
      options = []
      options << option(:foo, short: "-f map", convert: :map)
      options << option(:bar, short: "-b")

      params, = parse(%w[-f a:1 b:2 c:3 -b], options)

      expect(params[:foo]).to eq({a:"1", b:"2", c:"3"})
      expect(params[:bar]).to eq(true)
    end

    it "parses compacted short options with a separate map argument" do
      options = []
      options << option(:foo, short: "-f")
      options << option(:bar, short: "-b")
      options << option(:qux, short: "-q map", convert: :map)

      params, = parse(%w[-fbq a:1 b:2 c:3], options)

      expect(params[:foo]).to eq(true)
      expect(params[:bar]).to eq(true)
      expect(params[:qux]).to eq({a:"1", b:"2", c:"3"})
    end

    it "parses compacted short options with a map argument glued together" do
      options = []
      options << option(:foo, short: "-f")
      options << option(:bar, short: "-b")
      options << option(:qux, short: "-q map", convert: :map)

      params, = parse(%w[-fbqa:1 b:2 c:3], options)

      expect(params[:foo]).to eq(true)
      expect(params[:bar]).to eq(true)
      expect(params[:qux]).to eq({a:"1", b:"2", c:"3"})
    end

    it "parses long option with a map argument delimited by space" do
      options = []
      options << option(:foo, long: "--foo map", convert: :map)
      options << option(:bar, long: "--bar")

      params, rest = parse(%w[--foo a:1 b:2 c:3 --bar], options)

      expect(params[:foo]).to eq({a:"1", b:"2", c:"3"})
      expect(params[:bar]).to eq(true)
      expect(rest).to eq([])
    end

    it "parses long option with a map argument delimited by ampersand" do
      options = []
      options << option(:foo, long: "--foo map", convert: :map)
      options << option(:bar, long: "--bar")

      params, rest = parse(%w[--foo a:1&b:2&c:3 --bar], options)

      expect(params[:foo]).to eq({a:"1", b:"2", c:"3"})
      expect(params[:bar]).to eq(true)
      expect(rest).to eq([])
    end

    it "parses long option with a map argument and assigment symbol" do
      options = []
      options << option(:foo, long: "--foo=map", convert: :map)

      params, = parse(%w[--foo=a:1 b:2 c:3], options)

      expect(params[:foo]).to eq({a:"1", b:"2", c:"3"})
    end

    it "doesn't mix maps from other long options" do
      options = []
      options << option(:foo, long: "--foo map", convert: :int_map)
      options << option(:bar, long: "--bar map", convert: :int_map)

      params, rest = parse(%w[--foo a:1 b:2 c:3 --bar x:1 y:2], options)

      expect(params[:foo]).to eq({a:1, b:2, c:3})
      expect(params[:bar]).to eq({x:1, y:2})
      expect(rest).to eq([])
    end

    it "combines multiple options with map arguments" do
      options = []
      options << option(:foo, short: "-f map", convert: :int_map, arity: :any)

      params, rest = parse(%w[-f a:1 b:2 -f c:3 d:4], options)

      expect(params[:foo]).to eq({a:1, b:2, c:3, d: 4})
      expect(rest).to eq([])
    end

    it "parses option with an empty map" do
      options = []
      options << option(:foo, long: "--foo=map", convert: :map)

      params, = parse(%w[--foo=], options)

      expect(params[:foo]).to eq({})
    end
  end
end
