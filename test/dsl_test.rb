require 'test_helper'

class DSLTest < Minitest::Test
  def test_initial_block
    commands = assert_valid do
      initial do
        say 'Hello world'
        gamemode 0, @a
      end
    end
    assert_equal [
      'say Hello world',
      'gamemode 0 @a'
    ], commands
  end
end
