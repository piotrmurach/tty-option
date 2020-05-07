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

  context "action" do
    it "changes action via property" do
      usage = described_class.new(action: "foo")
      expect(usage.action).to eq("foo")
    end

    it "changes action via method" do
      usage = described_class.new
      expect(usage.action?).to eq(false)

      usage.action "foo"

      expect(usage.action).to eq(["foo"])
      expect(usage.action?).to eq(true)
    end

    it "configures many actions via method" do
      usage = described_class.new
      expect(usage.action?).to eq(false)

      usage.actions "foo", "bar", "baz"

      expect(usage.action).to eq(%w[foo bar baz])
      expect(usage.action?).to eq(true)
    end

    it "configures no action via method" do
      usage = described_class.new(action: "foo")
      expect(usage.action?).to eq(true)

      usage.no_action

      expect(usage.action).to eq([])
      expect(usage.action?).to eq(false)
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
    it "adds multiline description via property" do
      usage = described_class.new(desc: "Some description")
      expect(usage.desc).to eq([["Some description"]])
    end

    it "adds mulitline description wrapped in array via property" do
      usage = described_class.new(desc: ["Some description"])
      expect(usage.desc).to eq([["Some description"]])
    end

    it "adds multiline description as a separate arguments via method" do
      usage = described_class.new
      expect(usage.description?).to be(false)

      usage.description "Some description", "on multiline"

      expect(usage.description?).to eq(true)
      expect(usage.description).to eq([["Some description", "on multiline"]])
    end

    it "adds multiline description as a single string via method" do
      usage = described_class.new
      expect(usage.desc?).to be(false)

      usage.desc unindent(<<-EOS)
        Some description
        on multiline
      EOS

      expect(usage.desc?).to eq(true)
      expect(usage.desc).to eq([["Some description\non multiline\n"]])
    end
  end

  context "example" do
    it "adds multiline description via property" do
      usage = described_class.new(example: "Some example")
      expect(usage.example).to eq([["Some example"]])
    end

    it "adds mulitline description wrapped in array via property" do
      usage = described_class.new(example: ["Some example"])
      expect(usage.example).to eq([["Some example"]])
    end

    it "adds multiline example as separate arguments" do
      usage = described_class.new
      expect(usage.examples?).to eq(false)

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

  context "to_h" do
    it "returns all properties as hash" do
      usage = described_class.new do
        header "Header"
        program "Program"
        desc "Description"
        example "Example"
        footer "Footer"
      end

      expect(usage.to_h).to eq({
        desc: [["Description"]],
        example: [["Example"]],
        footer: "Footer",
        header: "Header",
        program: "Program"
      })
    end

    it "transforms hash via a block" do
      usage = described_class.new do
        header "Header"
        program "Program"
        desc "Description"
        example "Example"
        footer "Footer"
      end

      transformed = usage.to_h { |k, v| [k.to_s, v] }

      expect(transformed).to eq({
        "desc" => [["Description"]],
        "example" => [["Example"]],
        "footer" => "Footer",
        "header" => "Header",
        "program" => "Program"
      })
    end
  end
end
