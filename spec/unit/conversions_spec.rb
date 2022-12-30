# frozen_string_literal: true

require "date"
require "pathname"
require "uri"

RSpec.describe TTY::Option::Conversions do
  let(:undefined) { TTY::Option::Const::Undefined }

  context "when :bool" do
    {
      1 => true,
      0 => false,
      :yes => true,
      :no => false,
      true => true,
      false => false,
      "yes" => true,
      "y" => true,
      "true" => true,
      "TRUE" => true,
      "t" => true,
      "1" => true,
      "no" => false,
      "n" => false,
      "false" => false,
      "FALSE" => false,
      "f" => false,
      "0" => false
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:bool].(input)).to eq(obj)
      end
    end

    it "fails to convert the 'tak' string" do
      expect(described_class[:bool].("tak")).to eq(undefined)
    end

    it "fails to convert nil" do
      expect(described_class[:bool].(nil)).to eq(undefined)
    end
  end

  context "when :date" do
    {
      "28/03/2020" => Date.parse("28/03/2020"),
      "March 28th 2020" => Date.parse("28/03/2020"),
      "Sun, March 28th, 2020" => Date.parse("28/03/2020"),
      Date.parse("28/03/2020") => Date.parse("28/03/2020")
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:date].(input)).to eq(obj)
      end
    end

    it "fails to convert a string" do
      expect(described_class[:date].("invalid")).to eq(undefined)
    end

    it "fails to convert nil" do
      expect(described_class[:date].(nil)).to eq(undefined)
    end
  end

  context "when :float" do
    {
      1.0 => 1.0,
      1 => 1.0,
      -1 => -1.0,
      "1" => 1.0,
      "+1" => 1.0,
      "-1" => -1.0
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:float].(input)).to eq(obj)
      end
    end

    it "fails to convert a string" do
      expect(described_class[:float].("invalid")).to eq(undefined)
    end

    it "fails to convert nil" do
      expect(described_class[:float].(nil)).to eq(undefined)
    end
  end

  context "when :integer" do
    {
      1 => 1,
      1.0 => 1,
      -1.0 => -1,
      "1" => 1,
      "+1" => 1,
      "-1" => -1
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:int].(input)).to eq(obj)
      end
    end

    it "fails to convert a string" do
      expect(described_class[:int].("invalid")).to eq(undefined)
    end

    it "fails to convert nil" do
      expect(described_class[:integer].(nil)).to eq(undefined)
    end
  end

  context "when :pathname" do
    {
      "" => Pathname.new(""),
      "/foo/bar/baz.rb" => Pathname.new("/foo/bar/baz.rb"),
      Pathname.new("/foo/bar/baz.rb") => Pathname.new("/foo/bar/baz.rb")
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:pathname].(input)).to eq(obj)
      end
    end

    it "fails to convert a symbol" do
      expect(described_class[:path][:invalid]).to eq(undefined)
    end

    it "fails to convert nil" do
      expect(described_class[:path][nil]).to eq(undefined)
    end
  end

  context "when :regexp" do
    {
      "" => //,
      "foo" => /foo/,
      /foo/ => /foo/
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:regexp].(input)).to eq(obj)
      end
    end

    it "fails to convert a symbol" do
      expect(described_class[:regexp][:invalid]).to eq(undefined)
    end

    it "fails to convert nil" do
      expect(described_class[:regexp][nil]).to eq(undefined)
    end
  end

  context "when :symbol" do
    {
      nil => :"",
      :foo => :foo,
      "foo" => :foo,
      "1" => :"1",
      %w[foo] => :"[\"foo\"]"
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:sym].(input)).to eq(obj)
      end
    end

    it "fails to convert a BasicObject" do
      expect(described_class[:sym].(BasicObject.new)).to eq(undefined)
    end
  end

  context "when :uri" do
    {
      "" => URI.parse(""),
      "https://example.com" => URI.parse("https://example.com"),
      URI.parse("https://example.com") => URI.parse("https://example.com")
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:uri].(input)).to eq(obj)
      end
    end

    it "fails to convert an integer" do
      expect(described_class[:uri][123]).to eq(undefined)
    end

    it "fails to convert nil" do
      expect(described_class[:uri][nil]).to eq(undefined)
    end
  end

  context "when :list" do
    {
      "" => [],
      ",," => [],
      "a" => ["a"],
      :a => %i[a],
      1 => [1],
      true => [true],
      ",b,c" => %w[b c],
      "a,b,c" => %w[a b c],
      "a , b , c" => %w[a b c],
      "a, , c" => %w[a c],
      "a, b\\, c" => ["a", "b, c"],
      %w[a b c] => %w[a b c],
      [:a, " b ", 1, true] => [:a, " b ", 1, true]
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:list].(input)).to eq(obj)
      end
    end

    it "fails to convert nil to an array" do
      expect(described_class[:list].(nil)).to eq(undefined)
    end

    {
      [:bool_array, "t,t,f"] => [true, true, false],
      [:bool_list, %w[t t f]] => [true, true, false],
      [:bools, [true, true, false]] => [true, true, false],
      [:float_array, "1,2,3"] => [1.0, 2.0, 3.0],
      [:float_list, %w[1 2 3]] => [1.0, 2.0, 3.0],
      [:floats, [1, 2, 3]] => [1.0, 2.0, 3.0],
      [:int_array, "1,2,3"] => [1, 2, 3],
      [:int_list, %w[1 2 3]] => [1, 2, 3],
      [:ints, [1, 2, 3]] => [1, 2, 3],
      [:regexp_array, "a,b,c"] => [/a/, /b/, /c/],
      [:regexp_list, %w[a b c]] => [/a/, /b/, /c/],
      [:regexps, [/a/, /b/, /c/]] => [/a/, /b/, /c/],
      [:symbol_array, "a,b,c"] => %i[a b c],
      [:symbol_list, %w[a b c]] => %i[a b c],
      [:symbols, %i[a b c]] => %i[a b c]
    }.each do |(type, input), obj|
      it "converts #{input.inspect} to #{obj.inspect} #{type}" do
        expect(described_class[type].(input)).to eq(obj)
      end
    end

    it "fails to convert nil to an integer array" do
      expect(described_class[:int_list].(nil)).to eq(undefined)
    end

    it "fails to convert a string to an integer array" do
      expect(described_class[:int_list].("a,b,c")).to eq(undefined)
    end

    it "fails to convert a string to a boolean array" do
      expect(described_class[:bools].("tak,nie,tak")).to eq(undefined)
    end
  end

  context "when :map" do
    {
      "" => {},
      "a" => {a: nil},
      :a => {a: nil},
      1 => {1 => nil},
      true => {true => nil},
      "a=1" => {a: "1"},
      "a=1&b=2" => {a: "1", b: "2"},
      "a=&b=2" => {a: "", b: "2"},
      "a=1&b=2&a=3" => {a: %w[1 3], b: "2"},
      "a:1 b:2" => {a: "1", b: "2"},
      "a:1 b:2 a:3" => {a: %w[1 3], b: "2"},
      %w[a:1 b:2 c:3] => {a: "1", b: "2", c: "3"},
      %w[a=1 b=2 c=3] => {a: "1", b: "2", c: "3"},
      {a: :a, b: 1, c: true} => {a: :a, b: 1, c: true},
      {"a" => :a, "b" => 1, "c" => true} => {"a" => :a, "b" => 1, "c" => true}
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:map].(input)).to eq(obj)
      end
    end

    it "fails to convert nil to a hash" do
      expect(described_class[:map].(nil)).to eq(undefined)
    end

    {
      [:bool_hash, "a:t b:f c:t"] => {a: true, b: false, c: true},
      [:bool_map, {a: "t", b: "f", c: "t"}] => {a: true, b: false, c: true},
      [:float_hash, "a:1 b:2 c:3"] =>  {a: 1.0, b: 2.0, c: 3.0},
      [:float_map, {a: "1", b: "2", c: "3"}] =>  {a: 1.0, b: 2.0, c: 3.0},
      [:int_hash, "a:1 b:2 c:3"] =>  {a: 1, b: 2, c: 3},
      [:int_map, {a: "1", b: "2", c: "3"}] =>  {a: 1, b: 2, c: 3},
      [:regexp_hash, "a:t b:f c:t"] => {a: /t/, b: /f/, c: /t/},
      [:regexp_map, {a: "t", b: "f", c: "t"}] => {a: /t/, b: /f/, c: /t/},
      [:symbol_hash, "a:t b:f c:t"] => {a: :t, b: :f, c: :t},
      [:symbol_map, {a: "t", b: "f", c: "t"}] => {a: :t, b: :f, c: :t}
    }.each do |(type, input), obj|
      it "converts #{input.inspect} to #{obj.inspect} #{type}" do
        expect(described_class[type].(input)).to eq(obj)
      end
    end

    it "fails to convert nil to a hash with integer values" do
      expect(described_class[:int_map].(nil)).to eq(undefined)
    end

    it "fails to convert a string to a hash with integer values" do
      expect(described_class[:int_map].("a:a b:b")).to eq(undefined)
    end

    it "fails to convert a string to a hash with boolean values" do
      expect(described_class[:bool_map].("a:tak b:tak")).to eq(undefined)
    end
  end
end
