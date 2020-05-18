# frozen_string_literal: true

require_relative "../lib/tty-option"

module Network
  class Command
    include TTY::Option

    usage do
      program "network"
    end

    flag :force do
      short "-f"
      long "--force"
      desc "Do not prompt for confirmation"
    end

    option :help do
      short "-h"
      long "--help"
      desc "Display help information"
    end
  end

  class Connect < Command
    usage do
      program "network"
      desc "Connect to a network"
    end

    argument :network

    option :ip do
      long "--ip string"
      desc "IPv4 address (e.g., 172.30.100.104)"
    end
  end

  class Disconnect < Command
    usage do
      program "network"
      desc "Disconnect from a network"
    end

    argument :network
  end
end

connect = Network::Connect.new
puts connect.help

puts

disconnect = Network::Disconnect.new
puts disconnect.help
