# frozen_string_literal: true

RSpec.describe TTY::Option::Parameter::Environment do
  it "infers env var from the param name" do
    env = described_class.new(:foo)

    expect(env.arity).to eq(1)
    expect(env.variable).to eq("FOO")
    expect(env.var).to eq("FOO")
  end

  it "specifies custom env var name" do
    env = described_class.new(:foo, variable: "FOO_BAR")

    expect(env.arity).to eq(1)
    expect(env.variable).to eq("FOO_BAR")
    expect(env.var).to eq("FOO_BAR")
  end
end
