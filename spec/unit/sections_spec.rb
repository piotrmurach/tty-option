# frozen_string_literal: true

RSpec.describe TTY::Option::Sections do
  it "adds a section with content" do
    sections = described_class.new

    sections.add(:foo, "Foo content")
    sections.add(:bar, "Bar content")
    sections.add(:baz, "Baz content")

    expect(sections.size).to eq(3)
    expect(sections[:foo].content).to eq("Foo content")
    expect(sections[:bar].content).to eq("Bar content")
    expect(sections[:baz].content).to eq("Baz content")
  end

  it "deletes sections" do
    sections = described_class.new
    sections.add(:foo, "Foo content")
    sections.add(:bar, "Bar content")
    sections.add(:baz, "Baz content")

    sections.delete(:foo, :bar)

    expect(sections.map(&:name)).to eq([:baz])
  end

  it "replaces section" do
    sections = described_class.new
    sections.add(:foo, "Foo content")

    sections.replace(:foo, "New foo content")

    expect(sections[:foo].content).to eq("New foo content")
  end

  it "adds before existing section" do
    sections = described_class.new
    sections.add(:foo, "Foo content")

    sections.add_before(:foo, :bar, "Bar content")

    expect(sections.map(&:name)).to eq(%i[bar foo])
  end

  it "adds after existing section" do
    sections = described_class.new
    sections.add(:foo, "Foo content")
    sections.add(:bar, "Foo content")

    sections.add_after(:foo, :qux, "Qux content")

    expect(sections.map(&:name)).to eq(%i[foo qux bar])
  end

  it "fails add for non-existing section" do
    sections = described_class.new

    expect {
      sections.add_after(:foo, :bar, "Bar content")
    }.to raise_error(ArgumentError, "There is no section named: :foo")
  end
end
