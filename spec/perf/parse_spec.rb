# frozen_string_literal: true

require "optparse"
require "rspec-benchmark"

RSpec.describe TTY::Option, "#parse" do
  include RSpec::Benchmark::Matchers

  it "parses option with argument 3.5x slower than optparse" do
    cmd = new_command do
      include TTY::Option

      option :foo do
        short "-f string"
        long "--foo string"
      end
    end

    params = {}
    opt_parser = OptionParser.new do |opts|
      opts.on("-f string", "--foo string") do |val|
        params[:foo] = val
      end
    end

    argv = %w[--foo=bar]

    expect {
      cmd.parse(argv)
    }.to perform_slower_than {
      opt_parser.parse(argv)
    }.at_most(3.5).times
  end

  it "parses flag 5x slower than optparse" do
    cmd = new_command do
      include TTY::Option

      option :foo do
        short "-f"
        long "--foo"
      end
    end

    params = {}
    opt_parser = OptionParser.new do |opts|
      opts.on("-f", "--foo") do |val|
        params[:foo] = val
      end
    end

    argv = %w[--foo]

    expect {
      cmd.parse(argv)
    }.to perform_slower_than {
      opt_parser.parse(argv)
    }.at_most(5).times
  end

  it "parses argument allocating no more than 80 objects" do
    cmd = new_command do
      include TTY::Option

      argument :foo
    end
    argv = %w[bar]

    expect {
      cmd.parse(argv)
    }.to perform_allocation(80).objects
  end

  it "parses keyword allocating no more than 88 objects" do
    cmd = new_command do
      include TTY::Option

      keyword :foo
    end
    argv = %w[foo=bar]

    expect {
      cmd.parse(argv)
    }.to perform_allocation(88).objects
  end

  it "parses flag allocating no more than 95 objects" do
    cmd = new_command do
      include TTY::Option

      option :foo do
        short "-f"
        long "--foo"
      end
    end
    argv = %w[--foo]

    expect {
      cmd.parse(argv)
    }.to perform_allocation(95).objects
  end

  it "parses option with argument allocating no more than 97 objects" do
    cmd = new_command do
      include TTY::Option

      option :foo do
        short "-f string"
        long "--foo string"
      end
    end
    argv = %w[--foo=bar]

    expect {
      cmd.parse(argv)
    }.to perform_allocation(97).objects
  end

  it "parses environment variable allocating no more than 93 objects" do
    cmd = new_command do
      include TTY::Option

      env :foo
    end
    argv = %w[FOO=bar]

    expect {
      cmd.parse(argv)
    }.to perform_allocation(93).objects
  end
end
