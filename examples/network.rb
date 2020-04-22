# frozen_string_literal: true

require_relative "../lib/tty-option"

module Network
  class Create
    include TTY::Option

    argument :network do
      required
    end

    flag :attachable

    flag :config_only

    option :driver do
      short "-d"
      long "--driver string"
    end

    option :gateway do
      long "--gateway strings"
      convert :list
    end

    option :label do
      long "--label list"
      convert :list
    end

    option :options do
      short "-o"
      long "--opt map"
      convert :map
    end

    option :subnet do
      long "--subnet strings"
      convert :list
    end

    def execute
      p params.to_h
    end
  end
end

create = Network::Create.new

create.parse(%w[my-network --gateway host --driver overlay --opt a:1 b:2])

create.execute
