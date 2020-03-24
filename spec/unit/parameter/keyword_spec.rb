# frozen_string_literal: true

RSpec.describe TTY::Option::Parameter::Keyword do
  context "required/optional setting" do
    it "sets keyword presence optional by default" do
      kwarg = described_class.new(:foo)

      expect(kwarg.required?).to eq(false)
      expect(kwarg.optional?).to eq(true)
    end
  end
end
