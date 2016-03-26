class MockServer
  attr_reader :received_commands

  def initialize
    @matchers = []
    @message_matchers = []
    @received_commands = []
  end

  def start

  end

  def command(cmd)
    @received_commands << cmd
  end

  def say(message)
    @received_commands << "say #{message}"
  end

  def wait_for_line(match)

  end

  def on_line(match, &block)
    @matchers << [match, block]
  end

  def on_message(match, user=nil, &block)
    @message_matchers << [match, user, block]
  end

  def stop

  end

  def loop

  end

  def join

  end
end
