# frozen_string_literal: true

require "bigdecimal"
require "set"

RSpec.describe TTY::Option::DeepDup do
  [
    "foo",
    %w[foo bar],
    {"foo" => "bar"},
    Set.new(%w[foo bar])
  ].each do |obj|
    it "duplicates #{obj}" do
      dupped_obj = described_class.deep_dup(obj)

      expect(dupped_obj).to eq(obj)
      expect(dupped_obj).to_not equal(obj)
    end
  end

  [
    Class.new,
    Object.new
  ].each do |obj|
    it "duplicates #{obj}" do
      dupped_obj = described_class.deep_dup(obj)

      expect(dupped_obj).to_not equal(obj)
    end
  end

  [
    :foo,
    11,
    1.23,
    true,
    false,
    nil,
    method(:exec),
    BigDecimal("1.23")
  ].each do |obj|
    it "doesn't duplicate #{obj.class.name}" do
      dupped_obj = described_class.deep_dup(obj)

      expect(dupped_obj).to eq(obj)
      expect(dupped_obj).to equal(obj)
    end
  end

  it "duplicates nested hash" do
    obj = {
      "foo" => {
        "bar" => {
          "baz" => :qux
        }
      }
    }

    dupped_obj = described_class.deep_dup(obj)

    expect(dupped_obj).to eq(obj)
    expect(dupped_obj).to_not equal(obj)
    expect(dupped_obj.keys).to eq(obj.keys)
    expect(dupped_obj.keys).to_not equal(obj.keys)

    expect(dupped_obj["foo"]).to eq(obj["foo"])
    expect(dupped_obj["foo"]).to_not equal(obj["foo"])
    expect(dupped_obj["foo"].keys).to eq(obj["foo"].keys)
    expect(dupped_obj["foo"].keys).to_not equal(obj["foo"].keys)

    expect(dupped_obj["foo"]["bar"]).to eq(obj["foo"]["bar"])
    expect(dupped_obj["foo"]["bar"]).to_not equal(obj["foo"]["baz"])
    expect(dupped_obj["foo"]["bar"].keys).to eq(obj["foo"]["bar"].keys)
    expect(dupped_obj["foo"]["bar"].keys).to_not equal(obj["foo"]["bar"].keys)
  end

  it "duplicates nested array" do
    obj = [
      "foo",
      11,
      :bar,
      ["baz", {qux: {"quux" => true}}],
      false
    ]
    dupped_obj = described_class.deep_dup(obj)

    expect(dupped_obj).to eq(obj)
    expect(dupped_obj).to_not equal(obj)

    # "foo" is duplicated
    expect(dupped_obj[0]).to eq(obj[0])
    expect(dupped_obj[0]).to_not equal(obj[0])

    # 11 is not duplicated
    expect(dupped_obj[1]).to eq(obj[1])
    expect(dupped_obj[1]).to equal(obj[1])

    # :bar is not duplicated
    expect(dupped_obj[2]).to eq(obj[2])
    expect(dupped_obj[2]).to equal(obj[2])

    # array is duplicated
    expect(dupped_obj[3]).to eq(obj[3])
    expect(dupped_obj[3]).to_not equal(obj[3])

    # "baz" in array is duplicated
    expect(dupped_obj[3][0]).to eq(obj[3][0])
    expect(dupped_obj[3][0]).to_not equal(obj[3][0])

    # hash in array is duplicated
    expect(dupped_obj[3][1]).to eq(obj[3][1])
    expect(dupped_obj[3][1]).to_not equal(obj[3][1])

    # false is not duplicated
    expect(dupped_obj[4]).to eq(obj[4])
    expect(dupped_obj[4]).to equal(obj[4])
  end
end
