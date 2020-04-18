# frozen_string_literal: true

RSpec.describe TTY::Option::ParamConversion do
  it "converts parameter value to expected type" do
    param = TTY::Option::Parameter::Argument.create(:foo, convert: :int)

    expect(described_class[param, "12"]).to eq(12)
  end

  it "fails to convert parameter value to expected type" do
    param = TTY::Option::Parameter::Argument.create(:foo, convert: :int)

    error = described_class[param, "bar"]

    expect(error).to be_an_instance_of(TTY::Option::InvalidConversionArgument)
    expect(error.message).to eq("Invalid value of \"bar\" for :int conversion")
  end

  it "converts parameter value to expected type with a block" do
    param = TTY::Option::Parameter::Argument.create(:foo,
                                                    convert: ->(val) { val.to_i })

    expect(described_class[param, "12"]).to eq(12)
  end
end
