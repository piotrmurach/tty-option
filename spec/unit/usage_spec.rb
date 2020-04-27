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

  context "header" do
    it "changes header via property" do
      usage = described_class.new(header: "foo")
      expect(usage.header).to eq("foo")
    end

    it "changes header via method" do
      usage = described_class.new
      expect(usage.header?).to eq(false)

      usage.header("foo")

      expect(usage.header).to eq("foo")
      expect(usage.header?).to eq(true)
    end
  end

  context "banner" do
    it "changes banner via property" do
      usage = described_class.new(banner: "foo")
      expect(usage.banner).to eq("foo")
    end

    it "changes banner via method" do
      usage = described_class.new
      expect(usage.banner?).to eq(false)

      usage.banner("foo")

      expect(usage.banner).to eq("foo")
      expect(usage.banner?).to eq(true)
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

  context "example" do
    it "adds multiline example as separate arguments" do
      usage = described_class.new
      expect(usage.example?).to eq(false)

      usage.example "The following does something",
                    "  $ foo bar"

      expect(usage.example).to eq([["The following does something", "  $ foo bar"]])
      expect(usage.example?).to eq(true)
    end

    it "adds multiline example as a single string" do
      usage = described_class.new
      expect(usage.example?).to eq(false)

      usage.example unindent(<<-EOS)
      The following does something
        $ foo bar
      EOS
      expect(usage.example).to eq([["The following does something\n  $ foo bar\n"]])
      expect(usage.example?).to eq(true)
    end

    it "adds multiple examples" do
      usage = described_class.new
      expect(usage.example?).to eq(false)

      usage.example "foo"
      usage.example "bar"
      usage.example "baz"

      expect(usage.example).to eq([["foo"], ["bar"], ["baz"]])
      expect(usage.example?).to eq(true)
    end
  end

  context "footer" do
    it "changes footer via property" do
      usage = described_class.new(footer: "foo")
      expect(usage.footer).to eq("foo")
    end

    it "changes footer via method" do
      usage = described_class.new
      expect(usage.footer?).to eq(false)

      usage.footer("foo")

      expect(usage.footer).to eq("foo")
      expect(usage.footer?).to eq(true)
    end
  end
end
