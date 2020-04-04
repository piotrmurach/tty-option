# frozen_string_literal: true

RSpec.describe TTY::Option::Pipeline do
  it "processes param value through various checks" do
    param = TTY::Option::Parameter::Option.create(:foo, convert: :int, validate: '\d+')
    expect(described_class.process(param, "12")).to eq(12)
  end
end
