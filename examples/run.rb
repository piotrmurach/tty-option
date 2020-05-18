# frozen_string_literal: true

require_relative "../lib/tty-option"

class RunImage
  include TTY::Option

  usage do
    program "dock"

    command "run"

    desc "Run a command in a new container"

    example "Set working directory (-w)",
            "  $ dock run -w /path/to/dir/ ubuntu pwd"

    example <<~EOS
    Mount volume
      $ dock run -v `pwd`:`pwd` -w `pwd` ubuntu pwd
    EOS
  end

  argument :image do
    required
    desc "The name of the image to use"
  end

  argument :command do
    optional
    desc "The command to run inside the image"
  end

  keyword :restart do
    default "no"
    permit %w[no on-failure always unless-stopped]
    desc "Restart policy to apply when a container exits"
  end

  flag :help do
    short "-h"
    long "--help"
    desc "Print usage"
  end

  flag :detach do
    short "-d"
    long "--detach"
    desc "Run container in background and print container ID"
  end

  option :name do
    required
    long "--name string"
    desc "Assign a name to the container"
  end

  option :port do
    arity one_or_more
    short "-p"
    long "--publish list"
    convert :list
    desc "Publish a container's port(s) to the host"
  end

  def run
    if params[:help]
      print help
    elsif params.errors.any?
      puts params.errors.summary
    else
      pp params.to_h
    end
  end
end

cmd = RunImage.new

# show parsed params
cmd.parse(%w[restart=always -d -p 5000:3000 5001:8080 --name web ubuntu:16.4 bash])
cmd.run

# show help
cmd.parse(%w[--help])
cmd.run

# show errors
cmd.parse(%w[--unknown])
cmd.run
