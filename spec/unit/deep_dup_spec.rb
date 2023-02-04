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
    method(:exec).unbind,
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

  it "deep copies strings with the same identity only once" do
    foo = "foo"
    obj = [foo, foo, {baz: foo}]

    copied_obj = described_class.deep_dup(obj)

    # the copy has the same number of elements
    expect(copied_obj.size).to eq(obj.size)

    # the array is copied
    expect(copied_obj).to eq(obj)
    expect(copied_obj).not_to equal(obj)

    # the first array foo string is copied
    expect(copied_obj[0]).to eq(obj[0])
    expect(copied_obj[0]).not_to equal(obj[0])

    # the first and second array foo strings have the same identity
    expect(copied_obj[0]).to eq(copied_obj[1])
    expect(copied_obj[0]).to equal(copied_obj[1])

    # the first array and hash value foo strings have the same identity
    expect(copied_obj[0]).to eq(copied_obj[2][:baz])
    expect(copied_obj[0]).to equal(copied_obj[2][:baz])
  end

  it "deep copies arrays with the same identity only once" do
    foo = "foo"
    array = [foo, foo]
    obj = [array, array]

    copied_obj = described_class.deep_dup(obj)

    # the copy has the same number of elements
    expect(copied_obj.size).to eq(obj.size)

    # the outer array is copied
    expect(copied_obj).to eq(obj)
    expect(copied_obj).not_to equal(obj)

    # the first inner array is copied
    expect(copied_obj[0]).to eq(obj[0])
    expect(copied_obj[0]).not_to equal(obj[0])

    # the second inner array has the same identity as the first inner array
    expect(copied_obj[0]).to eq(copied_obj[1])
    expect(copied_obj[0]).to equal(copied_obj[1])

    # the first inner array foo string is copied
    expect(copied_obj[0][0]).to eq(obj[0][0])
    expect(copied_obj[0][0]).not_to equal(obj[0][0])

    # the foo strings in the first inner array have the same identity
    expect(copied_obj[0][0]).to eq(copied_obj[0][1])
    expect(copied_obj[0][0]).to equal(copied_obj[0][1])

    # the foo strings in the second inner array have the same identity
    expect(copied_obj[0][0]).to eq(copied_obj[1][0])
    expect(copied_obj[0][0]).to equal(copied_obj[1][0])
    expect(copied_obj[0][0]).to eq(copied_obj[1][1])
    expect(copied_obj[0][0]).to equal(copied_obj[1][1])
  end

  it "deep copies hashes with the same identity only once" do
    foo = "foo"
    bar = Set.new(%w[bar])
    baz = Set.new(%w[baz])
    hash = {bar => foo, baz => foo}
    obj = {bar => hash, baz => hash}

    copied_obj = described_class.deep_dup(obj)

    # the copy has the same number of pairs
    expect(copied_obj.size).to eq(obj.size)

    # the outer hash is copied
    expect(copied_obj).to eq(obj)
    expect(copied_obj).not_to equal(obj)

    # the outer hash keys are copied
    expect(copied_obj.keys[0]).to eq(obj.keys[0])
    expect(copied_obj.keys[0]).not_to equal(obj.keys[0])
    expect(copied_obj.keys[1]).to eq(obj.keys[1])
    expect(copied_obj.keys[1]).not_to equal(obj.keys[1])

    # the first inner hash is copied
    expect(copied_obj[bar]).to eq(obj[bar])
    expect(copied_obj[bar]).not_to equal(obj[bar])

    # the second inner hash has the same identity as the first hash
    expect(copied_obj[bar]).to eq(copied_obj[baz])
    expect(copied_obj[bar]).to equal(copied_obj[baz])

    # the outer and inner hash keys have the same identity
    expect(copied_obj.keys[0]).to eq(copied_obj[bar].keys[0])
    expect(copied_obj.keys[0]).to equal(copied_obj[bar].keys[0])
    expect(copied_obj.keys[1]).to eq(copied_obj[bar].keys[1])
    expect(copied_obj.keys[1]).to equal(copied_obj[bar].keys[1])

    # the first inner hash foo value is copied
    expect(copied_obj[bar][bar]).to eq(obj[bar][bar])
    expect(copied_obj[bar][bar]).not_to equal(obj[bar][bar])

    # the first inner hash foo values have the same identity
    expect(copied_obj[bar][bar]).to eq(copied_obj[bar][baz])
    expect(copied_obj[bar][bar]).to equal(copied_obj[bar][baz])

    # the second inner hash values have the same identity
    expect(copied_obj[bar][bar]).to eq(copied_obj[baz][bar])
    expect(copied_obj[bar][bar]).to equal(copied_obj[baz][bar])
    expect(copied_obj[bar][bar]).to eq(copied_obj[baz][baz])
    expect(copied_obj[bar][bar]).to equal(copied_obj[baz][baz])
  end

  it "deep copies recursive array" do
    obj = []
    obj << obj
    obj << obj

    copied_obj = described_class.deep_dup(obj)

    # the copy has the same number of elements
    expect(copied_obj.size).to eq(obj.size)

    # the outer array is copied
    expect(copied_obj).to eql(obj)
    expect(copied_obj).not_to equal(obj)

    # the inner arrays have the same identity as the outer array
    expect(copied_obj[0]).to eq(copied_obj)
    expect(copied_obj[0]).to equal(copied_obj)
    expect(copied_obj[1]).to eq(copied_obj)
    expect(copied_obj[1]).to equal(copied_obj)
  end

  it "deep copies recursive hash" do
    obj = {}
    obj["foo"] = obj
    obj["bar"] = obj

    copied_obj = described_class.deep_dup(obj)

    # the copy has the same number of pairs
    expect(copied_obj.size).to eq(obj.size)

    # the outer hash is copied
    expect(copied_obj).to eq(obj)
    expect(copied_obj).not_to equal(obj)

    # the values have the same identity as the outer hash
    expect(copied_obj["foo"]).to eq(copied_obj)
    expect(copied_obj["foo"]).to equal(copied_obj)
    expect(copied_obj["bar"]).to eq(copied_obj)
    expect(copied_obj["bar"]).to equal(copied_obj)
  end
end
