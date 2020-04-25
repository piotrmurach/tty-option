# frozen_string_literal: true

RSpec.describe TTY::Option::Formatter do
  def command(&block)
    stub_const("Command", Class.new)
    Command.send :include, TTY::Option
    Command.class_eval(&block)
    Command
  end

  def new_command(&block)
    command(&block).new
  end

  it "prints help information for options" do
    cmd = new_command do
      option :foo do
        short "-f"
        long "--foo string"
        desc "Some description"
      end

      option :bar do
        short "-b"
        long "--bar string"
        default "baz"
        desc "Some description"
      end

      option :qux do
        long "--qux-long ints"
        desc "Some description"
        default [1,2,3]
      end

      flag :fum do
        long "--fum"
        desc "Some description"
      end

      flag :baz

      flag :corge do
        short "-c"
        desc "Some description"
      end
    end

    expected_output = unindent(<<-EOS).strip
    Options:
      -b, --bar string      Some description (default "baz")
          --baz
      -f, --foo string      Some description
          --fum             Some description
          --qux-long ints   Some description (default [1, 2, 3])
      -c                    Some description
    EOS

    expect(cmd.help).to eq(expected_output)
  end
end
