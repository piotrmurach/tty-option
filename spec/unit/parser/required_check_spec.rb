# frozen_string_literal: true

RSpec.describe TTY::Option::Parser::RequiredCheck do
  it "passes required check" do
    param = TTY::Option::Parameter::Option.create(:foo, required: true)
    errors = []
    aggregator = ->(err) { errors << err }
    required_check = described_class.new(aggregator)
    required_check << param

    required_check.delete(param)

    required_check.()

    expect(errors).to eq([])
  end

  it "fails required check" do
    param = TTY::Option::Parameter::Option.create(:foo)
    errors = []
    aggregator = ->(err) { errors << err }
    required_check = described_class.new(aggregator)
    required_check << param

    required_check.()

    error = TTY::Option::MissingParameter.new(new_parameter("option", :foo))

    expect(errors).to eq([error])
  end
end
