# frozen_string_literal: true

RSpec.describe TTY::Option::ParamValidation do
  it "skips validation when no validate setting" do
    param = TTY::Option::Parameter::Option.create(:foo)

    expect(described_class[param, "12"]).to eq("12")
  end

  it "accepts an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d+/)

    expect(described_class[param, "12"]).to eq("12")
  end

  it "accepts multiple values in an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d+/)

    expect(described_class[param, %w[12 13 14]]).to eq(%w[12 13 14])
  end

  it "fails to accept an option parameter as valid" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d+/)

    error = described_class[param, "bar"]

    expect(error).to be_an_instance_of(TTY::Option::InvalidArgument)
    expect(error.message).to eq(
      "value of `bar` fails validation rule for :foo parameter"
    )
  end

  it "accepts a pram and fails another" do
    param = TTY::Option::Parameter::Option.create(:foo, validate: /\d{2,}/)
    error = TTY::Option::InvalidArgument.new(
              "value of `4` fails validation rule for :foo parameter")

    expect(described_class[param, %w[12 13 4]]).to eq(["12", "13", error])
  end
end
