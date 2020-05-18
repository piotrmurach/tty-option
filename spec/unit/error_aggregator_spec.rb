# frozen_string_literal: true

RSpec.describe TTY::Option::ErrorAggregator do
  it "raises error by default" do
    aggregator = described_class.new(raise_on_parse_error: true)
    expect {
      aggregator.(TTY::Option::MissingParameter, "boom")
    }.to raise_error(TTY::Option::MissingParameter, "boom")
  end

  it "collects errors as classes with custom messages" do
    aggregator = described_class.new

    aggregator.(TTY::Option::MissingParameter, "foo boom")
    aggregator.(TTY::Option::MissingParameter, "bar boom")

    expect(aggregator.errors.map { |e| [e.class, e.message] }).to eq([
      [TTY::Option::MissingParameter, "foo boom"],
      [TTY::Option::MissingParameter, "bar boom"]
    ])
  end

  it "collects errors as instances with custom messages" do
    aggregator = described_class.new
    foo_param = TTY::Option::Parameter::Option.create(:foo)
    bar_param = TTY::Option::Parameter::Option.create(:bar)

    foo_error = TTY::Option::MissingParameter.new(foo_param)
    bar_error = TTY::Option::MissingParameter.new(bar_param)

    aggregator.(foo_error)
    aggregator.(bar_error)

    expect(aggregator.errors).to eq([foo_error, bar_error])
  end

  it "collects unknown error instances with messages" do
    aggregator = described_class.new

    foo_error = TTY::Option::MissingParameter.new("foo boom")
    bar_error = TTY::Option::MissingParameter.new("bar boom")

    aggregator.(foo_error)
    aggregator.(bar_error)

    expect(aggregator.errors).to eq([foo_error, bar_error])
  end
end
