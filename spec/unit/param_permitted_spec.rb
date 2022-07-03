# frozen_string_literal: true

RSpec.describe TTY::Option::ParamPermitted do
  it "skips check when no permit setting" do
    param = TTY::Option::Parameter::Option.create(:foo)

    expect(described_class[param, "a"].value).to eq("a")
  end

  it "skips checking nil value" do
    param = TTY::Option::Parameter::Option.create(:foo, permit: %w[a b c])

    result = described_class[param, nil]

    expect(result.value).to eq(nil)
    expect(result.error).to eq(nil)
  end

  it "permits an option argument" do
    param = TTY::Option::Parameter::Option.create(:foo, permit: %w[a b c])

    expect(described_class[param, "a"].value).to eq("a")
  end

  it "doesn't permit an option argument" do
    param = TTY::Option::Parameter::Option.create(:foo, permit: %w[a b c])

    result = described_class[param, "d"]

    expect(result.value).to eq(nil)
    expect(result.error[0]).to be_an_instance_of(TTY::Option::UnpermittedArgument)
    expect(result.error[0].message).to eq(
      "unpermitted value `d` for '--foo' option: choose from a, b, c")
  end

  it "permits all values checked against an array of allowed values" do
    param = TTY::Option::Parameter::Argument.create(:foo, permit: %w[a b c])

    result = described_class[param, %w[a b]]

    expect(result.value).to eq(%w[a b])
    expect(result.error).to eq(nil)
  end

  it "doesn't permit values checked against an array of allowed values" do
    param = TTY::Option::Parameter::Argument.create(:foo, permit: %w[a b c])

    result = described_class[param, %w[a d e]]

    expect(result.value).to eq(nil)
    expect(result.error[0])
      .to be_an_instance_of(TTY::Option::UnpermittedArgument)
    expect(result.error[0].message).to eq(
      "unpermitted value `d` for 'foo' argument: choose from a, b, c")
    expect(result.error[1])
      .to be_an_instance_of(TTY::Option::UnpermittedArgument)
    expect(result.error[1].message).to eq(
      "unpermitted value `e` for 'foo' argument: choose from a, b, c")
  end

  it "permits all value pairs checked against a hash of allowed pairs" do
    param = TTY::Option::Parameter::Argument.create(:foo,
                                                    permit: {a: 1, b: 2, c: 3})

    result = described_class[param, {a: 1, b: 2}]

    expect(result.value).to eq({a: 1, b: 2})
    expect(result.error).to eq(nil)
  end

  it "doesn't permit value pairs checked against a hash of allowed pairs" do
    param = TTY::Option::Parameter::Argument.create(:foo,
                                                    permit: {a: 1, b: 2, c: 3})

    result = described_class[param, {b: 2, d: 4, e: 5}]

    expect(result.value).to eq(nil)
    expect(result.error[0])
      .to be_an_instance_of(TTY::Option::UnpermittedArgument)
    expect(result.error[0].message).to eq(
      "unpermitted value `d:4` for 'foo' argument: choose from a:1, b:2, c:3")
    expect(result.error[1])
      .to be_an_instance_of(TTY::Option::UnpermittedArgument)
    expect(result.error[1].message).to eq(
      "unpermitted value `e:5` for 'foo' argument: choose from a:1, b:2, c:3")
  end
end
