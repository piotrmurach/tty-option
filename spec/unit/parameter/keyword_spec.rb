# frozen_string_literal: true

RSpec.describe TTY::Option::Parameter::Keyword do
  context "required/optional setting" do
    it "sets keyword presence optional by default" do
      kwarg = described_class.new(:foo)

      expect(kwarg.required?).to eq(false)
      expect(kwarg.optional?).to eq(true)
    end
  end

  context "variable" do
    it "infers keyword var from the param name" do
      kwarg = described_class.new(:foo_bar)

      expect(kwarg.variable).to eq("foo-bar")
      expect(kwarg.var).to eq("foo-bar")
    end

    it "specifies custom keyword var name via a setting" do
      kwarg = described_class.new(:foo, variable: "foo-bar")

      expect(kwarg.variable).to eq("foo-bar")
      expect(kwarg.var).to eq("foo-bar")
    end

    it "specifies custom keywrod var name via a method" do
      kwarg = described_class.new(:foo)

      kwarg.variable "foo-bar"

      expect(kwarg.variable).to eq("foo-bar")
      expect(kwarg.var).to eq("foo-bar")
    end
  end
end
