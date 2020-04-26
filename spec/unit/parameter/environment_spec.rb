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

  context "comparison" do
    it "orders env vars by their display name" do
      env_a = described_class.new(:foo, var: "AAA")
      env_b = described_class.new(:bar, var: "BBB")
      env_c = described_class.new(:baz, var: "CCC")

      options = [env_b, env_c, env_a]

      expect(options.sort).to eq([env_a, env_b, env_c])
    end
  end
end
