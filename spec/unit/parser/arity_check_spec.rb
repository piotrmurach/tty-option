# frozen_string_literal: true

RSpec.describe TTY::Option::Parser::ArityCheck do
  it "passes arity check" do
    param = TTY::Option::Parameter::Option.create(:foo, arity: 2)
    errors = []
    aggregator = ->(err) { errors << err }
    arity_check = described_class.new(aggregator)
    arity_check << param

    arity_check.({foo: 2})

    expect(errors).to eq([])
  end

  it "fails arity check" do
    param = TTY::Option::Parameter::Option.create(:foo, arity: 2)
    errors = []
    aggregator = ->(err) { errors << err }
    arity_check = described_class.new(aggregator)
    arity_check << param

    arity_check.({foo: 1})

    error = TTY::Option::InvalidArity.new(
      "expected option '--foo' to appear 2 times but appeared 1 time")

    expect(errors.first).to eq(error)
  end
end
