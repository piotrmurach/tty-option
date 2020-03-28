# frozen_string_literal: true

require "date"

RSpec.describe TTY::Option::Conversions do
  context ":bool" do
    {
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

    it "fails to convert" do
      expect {
        described_class[:bool].("tak")
      }.to raise_error(TTY::Option::InvalidConversionArgument,
                      /Invalid value of "tak" for :bool conversion/)
    end
  end

  context ":date" do
    {
      "28/03/2020" => Date.parse("28/03/2020"),
      "March 28th 2020" => Date.parse("28/03/2020"),
      "Sun, March 28th, 2020" => Date.parse("28/03/2020")
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:date].(input)).to eq(obj)
      end
    end

    it "fails to convert" do
      expect {
        described_class[:date].("invalid")
      }.to raise_error(TTY::Option::InvalidConversionArgument,
                      /Invalid value of "invalid" for :date conversion/)
    end
  end

  context ":float" do
    {
      "1" => 1.0,
      "+1" => 1.0,
      "-1" => -1.0
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:float].(input)).to eq(obj)
      end
    end

    it "fails to convert" do
      expect {
        described_class[:float].("invalid")
      }.to raise_error(TTY::Option::InvalidConversionArgument,
                      /Invalid value of "invalid" for :float conversion/)
    end
  end

  context ":int" do
    {
      "1" => 1,
      "+1" => 1,
      "-1" => -1
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:int].(input)).to eq(obj)
      end
    end

    it "fails to convert" do
      expect {
        described_class[:int].("invalid")
      }.to raise_error(TTY::Option::InvalidConversionArgument,
                      /Invalid value of "invalid" for :int conversion/)
    end
  end

  context ":pathname" do
    it "covnerts string to a Pathname object" do
      path = described_class[:pathname].("/foo/bar/baz.rb")

      expect(path.dirname.to_s).to eq("/foo/bar")
      expect(path.basename.to_s).to eq("baz.rb")
    end
  end

  context ":regexp" do
    {
      "foo|bar" => /foo|bar/,
      true => /true/,
      1 => /1/,
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:regexp].(input)).to eq(obj)
      end
    end

    it "fails to convert" do
      expect {
        described_class[:regexp].([])
      }.to raise_error(TTY::Option::InvalidConversionArgument,
                      /Invalid value of \[\] for :regexp conversion/)
    end
  end

  context ":sym" do
    {
      "foo" => :foo,
      "1" => :"1",
      %w[foo] => :"[\"foo\"]"
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:sym].(input)).to eq(obj)
      end
    end
  end

  context ":uri" do
    it "converts string to URI object" do
      uri = described_class[:uri].("https://example.com")

      expect(uri.scheme).to eq("https")
      expect(uri.host).to eq("example.com")
    end

    it "fails to convert" do
      expect {
        described_class[:uri][123]
      }.to raise_error(TTY::Option::InvalidConversionArgument,
                      /Invalid value of 123 for :uri conversion/)
    end
  end

  context ":list" do
    {
      ",," => [],
      ",b,c" => %w[b c],
      "a,b,c" => %w[a b c],
      "a , b , c" => %w[a b c],
      "a, , c" => %w[a c],
      "a, b\\, c" => ["a", "b, c"],
      %w[a b c] => %w[a b c]
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:list].(input)).to eq(obj)
      end
    end

    {
      [:int_list, "1,2,3"] => [1, 2, 3],
      [:ints, "1,2,3"] => [1, 2, 3],
      [:float_list, "1,2,3"] => [1.0, 2.0, 3.0],
      [:floats, "1,2,3"] => [1.0, 2.0, 3.0],
      [:bool_list, "t,t,f"] => [true, true, false],
      [:bools, "t,t,f"] => [true, true, false],
      [:symbols, "a,b,c"] => [:a, :b, :c],
      [:regexps, "a,b,c"] => [/a/, /b/, /c/]
    }.each do |(type, input), obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[type].(input)).to eq(obj)
      end
    end
  end

  context ":map" do
    {
      "a=1" => {a: "1"},
      "a=1&b=2" => {a: "1", b: "2"},
      "a=&b=2" => {a: "", b: "2"},
      "a=1&b=2&a=3" => {a: ["1", "3"], b: "2"},
      "a:1 b:2" => {a: "1", b: "2"},
      "a:1 b:2 a:3" => {a: ["1", "3"], b: "2"},
      %w[a:1 b:2 c:3] => {a: "1", b: "2", c: "3"},
      %w[a=1 b=2 c=3] => {a: "1", b: "2", c: "3"},
    }.each do |input, obj|
      it "converts #{input.inspect} to #{obj.inspect}" do
        expect(described_class[:map].(input)).to eq(obj)
      end
    end
  end
end
