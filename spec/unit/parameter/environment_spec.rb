# frozen_string_literal: true

RSpec.describe TTY::Option::Parameter::Environment do
  context "name" do
    it "infers env name from the param key" do
      env = described_class.new(:foo_bar)

      expect(env.arity).to eq(1)
      expect(env.name).to eq("FOO_BAR")
    end

    it "specifies custom env var name via a setting" do
      env = described_class.new(:foo, name: "FOO_BAR")

      expect(env.name).to eq("FOO_BAR")
    end

    it "specifies custom env var name via a method" do
      env = described_class.new(:foo)

      env.name "FOO_BAR"

      expect(env.name).to eq("FOO_BAR")
    end
  end

  context "comparison" do
    it "orders env vars by their display name" do
      env_a = described_class.new(:foo, name: "AAA")
      env_b = described_class.new(:bar, name: "BBB")
      env_c = described_class.new(:baz, name: "CCC")

      options = [env_b, env_c, env_a]

      expect(options.sort).to eq([env_a, env_b, env_c])
    end
  end
end
