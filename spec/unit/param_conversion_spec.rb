# frozen_string_literal: true

RSpec.describe TTY::Option::ParamConversion do
  it "converts parameter value to expected type" do
    param = TTY::Option::Parameter::Argument.create(:foo, convert: :int)

    expect(described_class[param, "12"].value).to eq(12)
  end

  it "skips parameter conversion when the value is nil" do
    param = TTY::Option::Parameter::Argument.create(:foo, convert: :int)

    result = described_class[param, nil]

    expect(result.success?).to eq(true)
    expect(result.value).to eq(nil)
    expect(result.error).to eq(nil)
  end

  it "fails to convert parameter value to expected type" do
    param = TTY::Option::Parameter::Argument.create(:foo, convert: :int)

    result = described_class[param, "bar"]

    expect(result.value).to eq(nil)
    expect(result.error).to be_an_instance_of(TTY::Option::InvalidConversionArgument)
    expect(result.error.message).to eq(
      "cannot convert value of `bar` into 'int' type for 'foo' argument")
  end

  it "converts parameter value to expected type with a block" do
    param = TTY::Option::Parameter::Argument.create(:foo,
                                                    convert: ->(val) { val.to_i })

    expect(described_class[param, "12"].value).to eq(12)
  end
end
