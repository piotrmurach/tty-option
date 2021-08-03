# frozen_string_literal: true

RSpec.describe TTY::Option::Converter do
  let(:converter) do
    stub_const("Casting", Module.new do
      extend TTY::Option::Converter
    end)
    Casting
  end

  it "checks if conversion is defined" do
    expect(converter.contain?(:foo)).to eq(false)
  end

  it "checks if conversion is defined" do
    converter.convert(:foo) { "bar" }

    expect(converter.contain?(:foo)).to eq(true)
  end

  it "registers a new conversion" do
    converter.convert(:foo) { "bar" }

    expect(converter[:foo][]).to eq("bar")
  end

  it "stops registration of already defined conversion" do
    converter.convert(:foo) { "bar" }

    expect {
      converter.convert(:foo) { "baz" }
    }.to raise_error(TTY::Option::ConversionAlreadyDefined,
                     "conversion :foo is already defined")
  end

  it "reads unsupported conversion" do
    expect {
      converter[:unknown]
    }.to raise_error(TTY::Option::UnsupportedConversion,
                     "unsupported conversion type :unknown")
  end
end
