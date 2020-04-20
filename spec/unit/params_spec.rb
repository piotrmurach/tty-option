# frozen_string_literal: true

RSpec.describe TTY::Option::Params do
  it "allows indifferent access to keys via has like syntax" do
    params = described_class.new({foo: "bar"})

    expect(params[:foo]).to eq("bar")
    expect(params["foo"]).to eq("bar")
  end

  it "allows indifferent access to keys via fetch" do
    params = described_class.new({foo: "bar"})

    expect(params.fetch(:foo)).to eq("bar")
    expect(params.fetch("foo")).to eq("bar")
  end

  it "allows indifferent access to keys via fetch with defaults" do
    params = described_class.new({foo: "bar"})

    expect(params.fetch(:baz, false)).to eq(false)
    expect(params.fetch(:baz) { false }).to eq(false)
  end

  it "returns false for non empty parameters" do
    params = described_class.new({foo: "bar"})

    expect(params.empty?).to eq(false)
  end

  it "returns true when key?/has_key?/member? finds a given key" do
    params = described_class.new({foo: "bar"})

    expect(params.key?(:foo)).to eq(true)
    expect(params.has_key?(:foo)).to eq(true)
    expect(params.member?(:foo)).to eq(true)
  end

  it "returns false when key?/has_key?/member? doesn't find a given key" do
    params = described_class.new({foo: "bar"})

    expect(params.key?(:baz)).to eq(false)
    expect(params.has_key?(:baz)).to eq(false)
    expect(params.member?(:baz)).to eq(false)
  end

  it "returns true when value?/has_value? finds value" do
    params = described_class.new({foo: "bar"})

    expect(params.value?("bar")).to eq(true)
    expect(params.has_value?("bar")).to eq(true)
  end

  it "returns false when value?/has_value? doesn't find value" do
    params = described_class.new({foo: "bar"})

    expect(params.value?("baz")).to eq(false)
    expect(params.has_value?("baz")).to eq(false)
  end

  it "returns an array of the keys for the params" do
    params = described_class.new({a: 1, b: 2, c: 3})

    expect(params.keys).to eq([:a, :b, :c])
  end

  it "is equal to other Params object with the same parameters" do
    params_a = described_class.new({a: 1, b: 2})
    params_b = described_class.new({a: 1, b: 2})

    expect(params_a).to eq(params_b)
  end

  it "isn't equal to other Params object with different parameters" do
    params_a = described_class.new({a: 1, b: 2})
    params_b = described_class.new({a: 1, c: 3})

    expect(params_a).to_not eq(params_b)
  end

  it "returns string representation of internal parameters" do
    params = described_class.new({a: 1, b:2, c: 3})

    expect(params.to_s).to eq("{:a=>1, :b=>2, :c=>3}")
  end

  it "returns string representation of the class" do
    params = described_class.new({a: 1, b:2, c: 3})

    expect(params.inspect).to eq("#<TTY::Option::Params{:a=>1, :b=>2, :c=>3}>")
  end
end
