# frozen_string_literal: true

require_relative "../lib/tty-option"

class Command
  include TTY::Option

  argument :bar do
    arity at_least(2)
  end

  option :foo do
    arity one_or_more
    short "-f"
    long "--foo list"
    convert map_of(Integer)
  end
  
  def run
    p params[:bar]
    p params[:foo]
  end
end

cmd = Command.new

cmd.parse(%w[arg1 arg2 -f a:1 b:2 --foo c=3&d=4])

cmd.run
