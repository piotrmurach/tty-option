# frozen_string_literal: true

RSpec.describe TTY::Option::ParamPermitted do
  it "skips check when no permit setting" do
    param = TTY::Option::Parameter::Option.create(:foo)

    expect(described_class[param, "a"].value).to eq("a")
  end

  it "permits an option argument" do
    param = TTY::Option::Parameter::Option.create(:foo, permit: %w[a b c])

    expect(described_class[param, "a"].value).to eq("a")
  end

  it "doesn't permit an option arguemnt" do
    param = TTY::Option::Parameter::Option.create(:foo, permit: %w[a b c])

    result = described_class[param, "d"]

    expect(result.value).to eq(nil)
    expect(result.error).to be_an_instance_of(TTY::Option::UnpermittedArgument)
    expect(result.error.message).to eq(
      "unpermitted value `d` for '--foo' option: choose from a, b, c")
  end
end
