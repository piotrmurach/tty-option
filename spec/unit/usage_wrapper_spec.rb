# frozen_string_literal: true

require_relative "../../lib/tty/option/usage_wrapper"

RSpec.describe TTY::Option::UsageWrapper do
  it "doesn't wrap a line that fits the width" do
    text = "There is no stready"
    wrapped = described_class.wrap(text, width: 30, indent: 2)

    expect(wrapped).to eq(text)
  end

  it "wraps whitespace delimited content without any newlines" do
    text = "There is no steady unretracing progress in this life; we do not advance through fixed gradations, and at the last one pause"

    wrapped = described_class.wrap(text, width: 30, indent: 2)

    expect(wrapped).to eq <<-EOS.chomp
There is no steady
  unretracing progress in
  this life; we do not
  advance through fixed
  gradations, and at the last
  one pause
    EOS
  end

  it "wraps whitespace delimited content with newlines" do
    text = "There is no steady unretracing progress in this life;\n we do not advance through fixed gradations,\n and at the last one pause"

    wrapped = described_class.wrap(text, width: 30, indent: 2)

    expect(wrapped).to eq <<-EOS.chomp
There is no steady
  unretracing progress in
  this life;
  we do not advance through
  fixed gradations,
  and at the last one pause
    EOS
  end

  it "wraps blob of content without any whitespace" do
    text = "Thereisnosteadyunretracingprogressinthislife;wedonotadvancethroughfixedgradations,andatthelastonepause"

    wrapped = described_class.wrap(text, width: 30, indent: 2)

    expect(wrapped).to eq <<-EOS.chomp
Thereisnosteadyunretracingpr
  ogressinthislife;wedonotadva
  ncethroughfixedgradations,an
  datthelastonepause
    EOS
  end
end
