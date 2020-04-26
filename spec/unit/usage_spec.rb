# frozen_string_literal: true

RSpec.describe TTY::Option::Usage do
  context "program" do
    it "defaults program to current executable name" do
      usage = described_class.new
      expect(usage.program).to eq("rspec")
    end

    it "changes default program name via property" do
      usage = described_class.new(program: "foo")
      expect(usage.program).to eq("foo")
    end

    it "changes default program name via method" do
      usage = described_class.new
      usage.program("foo")
      expect(usage.program).to eq("foo")
    end
  end

  context "banner" do
    it "changes banner via property" do
      usage = described_class.new(banner: "foo")
      expect(usage.banner).to eq("foo")
    end

    it "changes banner via method" do
      usage = described_class.new
      usage.banner("foo")
      expect(usage.banner).to eq("foo")
    end
  end

  context "description" do
    it "changes description via property" do
      usage = described_class.new(desc: "Some description")
      expect(usage.desc).to eq("Some description")
    end

    it "changes description via method" do
      usage = described_class.new
      expect(usage.desc?).to be(false)

      usage.desc("Some description")

      expect(usage.desc?).to eq(true)
      expect(usage.desc).to eq("Some description")
    end
  end
end
