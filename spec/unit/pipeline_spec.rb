# frozen_string_literal: true

RSpec.describe TTY::Option::Pipeline do
  it "processes a param value through various transformation" do
    param = TTY::Option::Parameter::Option.create(:foo, convert: :int,
                                                  validate: '\d+')
    aggregator = ->(error) { errors << error }
    pipeline = described_class.new(aggregator)

    expect(pipeline.(param, "12")).to eq(12)
  end

  it "record a failure" do
    param = TTY::Option::Parameter::Option.create(:foo, convert: :int,
                                                  validate: '\d+')
    errors = []
    aggregator = ->(err) { errors << err }
    pipeline = described_class.new(aggregator)

    expect(pipeline.(param, "a")).to eq(nil)
    expect(errors.first).to be_an_instance_of(TTY::Option::InvalidConversionArgument)
  end
end
