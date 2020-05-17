# frozen_string_literal: true

RSpec.describe TTY::Option::ParamValidation do
  it "skips validation when no validate setting" do
    param = TTY::Option::Parameter::Option.create(:foo)

    expect(described_class[param, "12"].value).to eq("12")
  end

  it "accepts an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d+/)

    expect(described_class[param, "12"].value).to eq("12")
  end

  it "accepts multiple values in an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d+/)

    expect(described_class[param, %w[12 13 14]].value).to eq(%w[12 13 14])
  end

  it "fails to accept an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d+/)

    result = described_class[param, "bar"]

    expect(result.value).to eq(nil)
    expect(result.error[0]).to be_an_instance_of(TTY::Option::InvalidArgument)
    expect(result.error[0].message).to eq(
      "value of `bar` fails validation for '--foo' option"
    )
  end

  it "accepts a pram and fails another" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d{2,}/)
    error = TTY::Option::InvalidArgument.new(
              "value of `4` fails validation for '--foo' option")

    result = described_class[param, %w[12 13 4]]

    expect(result.value).to eq(nil)
    expect(result.error).to eq([error])
  end
end
