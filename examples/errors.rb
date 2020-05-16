# frozen_string_literal: true

require_relative "../lib/tty-option"

class Command
  include TTY::Option

  argument :foo do
    arity at_least(2)
  end

  option :bar do
    arity one_or_more
    short "-b"
    long "--bar int"
    convert map_of(:int)
  end

  keyword :baz do
    required
    convert :date
  end

  env :qux do
    required
  end

  def run
    puts params.errors.summary
  end
end

cmd = Command.new

cmd.parse(%w[--unknown arg1 baz=1 --bar a:zzz])

cmd.run
