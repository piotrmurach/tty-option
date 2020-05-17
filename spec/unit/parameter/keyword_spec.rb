# frozen_string_literal: true

RSpec.describe TTY::Option::Parameter::Keyword do
  context "required/optional setting" do
    it "sets keyword presence optional by default" do
      kwarg = described_class.new(:foo)

      expect(kwarg.required?).to eq(false)
      expect(kwarg.optional?).to eq(true)
    end
  end

  context "name" do
    it "infers keyword name from the param key" do
      kwarg = described_class.new(:foo_bar)

      expect(kwarg.name).to eq("foo-bar")
    end

    it "specifies custom keyword name via a setting" do
      kwarg = described_class.new(:foo, name: "foo-bar")

      expect(kwarg.name).to eq("foo-bar")
    end

    it "specifies custom keywrod name via a method" do
      kwarg = described_class.new(:foo)

      kwarg.name "foo-bar"

      expect(kwarg.name).to eq("foo-bar")
    end
  end
end
