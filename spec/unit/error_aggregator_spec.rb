# frozen_string_literal: true

RSpec.describe TTY::Option::ErrorAggregator do
  it "raises error by default" do
    aggregator = described_class.new
    expect {
      aggregator.(TTY::Option::MissingParameter, "boom")
    }.to raise_error(TTY::Option::MissingParameter, "boom")
  end

  it "collects errors as classes with custom messages" do
    aggregator = described_class.new(raise_if_missing: false)

    aggregator.(TTY::Option::MissingParameter, "foo boom")
    aggregator.(TTY::Option::MissingParameter, "bar boom")

    expect(aggregator.errors).to eq({
      messages: [
        {missing_parameter: "foo boom"},
        {missing_parameter: "bar boom"}
      ]
    })
  end

  it "collects errors as instances with custom messages" do
    aggregator = described_class.new(raise_if_missing: false)
    foo_param = TTY::Option::Parameter::Option.create(:foo)
    bar_param = TTY::Option::Parameter::Option.create(:bar)

    foo_error = TTY::Option::MissingParameter.new(foo_param)
    bar_error = TTY::Option::MissingParameter.new(bar_param)

    aggregator.(foo_error, "foo boom")
    aggregator.(bar_error, "bar boom")

    expect(aggregator.errors).to eq({
      foo: {missing_parameter: "foo boom"},
      bar: {missing_parameter: "bar boom"}
    })
  end

  it "collects unknown error instances with messages" do
    aggregator = described_class.new(raise_if_missing: false)

    foo_error = TTY::Option::MissingParameter.new("foo boom")
    bar_error = TTY::Option::MissingParameter.new("bar boom")

    aggregator.(foo_error)
    aggregator.(bar_error)

    expect(aggregator.errors).to eq({
      messages: [
        {missing_parameter: "foo boom"},
        {missing_parameter: "bar boom"}
      ]
    })
  end
end
