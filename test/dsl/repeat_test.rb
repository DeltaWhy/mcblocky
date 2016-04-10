require 'test_helper'

class RepeatTest < Minitest::Test
  def test_repeat
    commands = assert_valid do
      repeat 1, 2, 3, 5, 5, 5 do
        say 'Hello'
        say 'World'
      end
    end
    assert_includes commands[0], 'minecraft:repeating_command_block'
    assert_includes commands[1], 'auto:1'
    assert_includes commands[2], 'minecraft:chain_command_block'
    assert_includes commands[3], 'auto:1'
  end

  def test_named_repeat
    commands = assert_valid do
      repeat :foo, 1, 2, 3, 5, 5, 5 do
        say 'Hello'
        say 'World'
      end
    end
    assert_includes commands[0], 'setblock 1 2 3'
  end

  def test_enable_disable_repeat
    commands = assert_valid do
      repeat :foo, 1, 2, 3, 5, 5, 5 do
        say 'Hello'
        say 'World'
      end
      after do
        disable :foo
        enable :foo
      end
    end
    assert_equal 'blockdata 1 2 3 {auto:0}', commands[-2]
    assert_equal 'blockdata 1 2 3 {auto:1}', commands[-1]
  end
end
