# frozen_string_literal: true

RSpec.describe TTY::Option::ErrorAggregator do
  it "raises error by default" do
    aggregator = described_class.new
    expect {
      aggregator.(TTY::Option::MissingParameter, "boom")
    }.to raise_error(TTY::Option::MissingParameter, "boom")
  end

  it "collects errors as class" do
    aggregator = described_class.new(raise_if_missing: false)
    foo_param = TTY::Option::Parameter::Option.create(:foo)
    bar_param = TTY::Option::Parameter::Option.create(:bar)

    aggregator.(TTY::Option::MissingParameter, "foo boom", foo_param)
    aggregator.(TTY::Option::MissingParameter, "bar boom", bar_param)

    expect(aggregator.errors).to eq({
      foo: {missing_parameter: "foo boom"},
      bar: {missing_parameter: "bar boom"}
    })
  end

  it "collects errors as instances" do
    aggregator = described_class.new(raise_if_missing: false)
    foo_param = TTY::Option::Parameter::Option.create(:foo)
    bar_param = TTY::Option::Parameter::Option.create(:bar)

    foo_error = TTY::Option::MissingParameter.new("foo boom")
    bar_error = TTY::Option::MissingParameter.new("bar boom")

    aggregator.(foo_error, foo_error.message, foo_param)
    aggregator.(bar_error, bar_error.message, bar_param)

    expect(aggregator.errors).to eq({
      foo: {missing_parameter: "foo boom"},
      bar: {missing_parameter: "bar boom"}
    })
  end

  it "collects unknown error messages" do
    aggregator = described_class.new(raise_if_missing: false)

    foo_error = TTY::Option::MissingParameter.new("foo boom")
    bar_error = TTY::Option::MissingParameter.new("bar boom")

    aggregator.(foo_error, foo_error.message)
    aggregator.(bar_error, bar_error.message)

    expect(aggregator.errors).to eq({
      messages: [
        {missing_parameter: "foo boom"},
        {missing_parameter: "bar boom"}
      ]
    })
  end
end
