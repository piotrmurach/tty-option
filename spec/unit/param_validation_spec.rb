# frozen_string_literal: true

RSpec.describe TTY::Option::ParamValidation do
  it "skips validation when no validate setting" do
    param = TTY::Option::Parameter::Option.create(:foo)

    expect(described_class[param, "12"].value).to eq("12")
  end

  it "skips validation when the value is nil" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /^\d+$/)

    result = described_class[param, nil]

    expect(result).to be_an_instance_of(TTY::Option::Result::Success)
    expect(result).to have_attributes(value: nil, error: nil)
  end

  it "accepts a string for an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d+/)

    expect(described_class[param, "12"].value).to eq("12")
  end

  it "fails to accept a string for an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d+/)
    error = TTY::Option::InvalidArgument.new(
      "value of `bar` fails validation for '--foo' option")

    result = described_class[param, "bar"]

    expect(result).to have_attributes(value: nil, error: [error])
  end

  it "accepts an empty array for an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d{2,}/)

    result = described_class[param, []]

    expect(result).to have_attributes(value: [], error: nil)
  end

  it "accepts an array with many values for an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d+/)

    expect(described_class[param, %w[12 13 14]].value).to eq(%w[12 13 14])
  end

  it "fails to accept an array with many values as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d{2,}/)
    error = TTY::Option::InvalidArgument.new(
      "value of `4` fails validation for '--foo' option")

    result = described_class[param, %w[12 13 4]]

    expect(result).to have_attributes(value: nil, error: [error])
  end

  it "accepts an empty hash for an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate:
                                                  ->(v) { v[1] < 4 })

    result = described_class[param, {}]

    expect(result).to have_attributes(value: {}, error: nil)
  end

  it "accepts a hash with a single value for an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate:
                                                  ->(v) { v[1] < 4 })

    result = described_class[param, {a: 1}]

    expect(result).to have_attributes(value: {a: 1}, error: nil)
  end

  it "accepts a hash with many values for an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate:
                                                  ->(v) { v[1] < 4 })

    result = described_class[param, {a: 1, b: 2, c: 3}]

    expect(result).to have_attributes(value: {a: 1, b: 2, c: 3}, error: nil)
  end

  it "fails to accept a hash with many values as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate:
                                                  ->(v) { v[1] < 4 })
    error_c = TTY::Option::InvalidArgument.new(
      "value of `c:4` fails validation for '--foo' option")
    error_d = TTY::Option::InvalidArgument.new(
      "value of `d:5` fails validation for '--foo' option")

    result = described_class[param, {a: 1, b: 2, c: 4, d: 5}]

    expect(result).to have_attributes(value: nil, error: [error_c, error_d])
  end
end
