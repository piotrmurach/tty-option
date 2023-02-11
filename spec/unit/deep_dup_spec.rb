# frozen_string_literal: true

require "bigdecimal"
require "date"
require "pathname"
require "set"
require "uri"

RSpec.describe TTY::Option::DeepDup do
  [
    "foo",
    *(/foo/ unless RSpec::Support::Ruby.truffleruby?),
    %w[foo bar],
    (1..10),
    {"foo" => "bar"},
    Date.parse("11/02/2023"),
    Pathname.new("/foo/bar"),
    Set.new(%w[foo bar]),
    URI.parse("https://example.com")
  ].each do |obj|
    it "deep copies #{obj.class.name}" do
      copied_obj = described_class.deep_dup(obj)

      expect(copied_obj).to eq(obj)
      expect(copied_obj).not_to equal(obj)
    end
  end

  [
    Class.new,
    Object.new
  ].each do |obj|
    it "deep copies #{obj.class.name}" do
      copied_obj = described_class.deep_dup(obj)

      expect(copied_obj).not_to equal(obj)
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
    it "doesn't deep copy #{obj.class.name}" do
      copied_obj = described_class.deep_dup(obj)

      expect(copied_obj).to eq(obj)
      expect(copied_obj).to equal(obj)
    end
  end

  it "deep copies nested hash" do
    obj = {
      "foo" => {
        "bar" => {
          "baz" => :qux
        }
      }
    }

    copied_obj = described_class.deep_dup(obj)

    # the copy has the same number of pairs
    expect(copied_obj.size).to eq(obj.size)

    # the outer hash is copied
    expect(copied_obj).to eq(obj)
    expect(copied_obj).not_to equal(obj)

    # the inner hash is copied
    expect(copied_obj["foo"]).to eq(obj["foo"])
    expect(copied_obj["foo"]).not_to equal(obj["foo"])

    # the innermost hash is copied
    expect(copied_obj["foo"]["bar"]).to eq(obj["foo"]["bar"])
    expect(copied_obj["foo"]["bar"]).not_to equal(obj["foo"]["baz"])
  end

  it "deep copies nested array" do
    obj = [
      "foo",
      11,
      :bar,
      ["baz", {qux: {"quux" => true}}],
      false
    ]
    copied_obj = described_class.deep_dup(obj)

    # the copy has the same number of elements
    expect(copied_obj.size).to eq(obj.size)

    # the outer array is copied
    expect(copied_obj).to eq(obj)
    expect(copied_obj).not_to equal(obj)

    # the foo string is copied
    expect(copied_obj[0]).to eq(obj[0])
    expect(copied_obj[0]).not_to equal(obj[0])

    # the 11 integer is not copied
    expect(copied_obj[1]).to eq(obj[1])
    expect(copied_obj[1]).to equal(obj[1])

    # the bar symbol is not copied
    expect(copied_obj[2]).to eq(obj[2])
    expect(copied_obj[2]).to equal(obj[2])

    # the inner array is copied
    expect(copied_obj[3]).to eq(obj[3])
    expect(copied_obj[3]).not_to equal(obj[3])

    # the baz string inside the inner array is copied
    expect(copied_obj[3][0]).to eq(obj[3][0])
    expect(copied_obj[3][0]).not_to equal(obj[3][0])

    # the hash inside the inner array is copied
    expect(copied_obj[3][1]).to eq(obj[3][1])
    expect(copied_obj[3][1]).not_to equal(obj[3][1])

    # the false is not copied
    expect(copied_obj[4]).to eq(obj[4])
    expect(copied_obj[4]).to equal(obj[4])
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
