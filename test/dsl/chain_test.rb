require 'test_helper'

class ChainTest < Minitest::Test
  def test_chain
    commands = assert_valid do
      chain 1, 2, 3, 5, 5, 5 do
        say 'Hello'
        say 'World'
      end
    end
    assert_equal commands.length, 6
    assert_includes commands[0], 'minecraft:command_block'
    assert !commands[1].include?('auto:1')
    assert_includes commands[2], 'minecraft:chain_command_block'
    assert_includes commands[3], 'auto:1'
    assert_includes commands[4], 'minecraft:chain_command_block'
    assert_includes commands[5], 'blockdata'
    assert_includes commands[5], 'auto:0'
  end

  def test_named_chain
    commands = assert_valid do
      chain :foo, 1, 2, 3, 5, 5, 5 do
        say 'Hello'
        say 'World'
      end
    end
    assert_includes commands[0], 'setblock 1 2 3'
  end

  def test_activate_chain
    commands = assert_valid do
      chain :foo, 1, 2, 3, 5, 5, 5 do
        say 'Hello'
        say 'World'
      end
      after do
        activate :foo
      end
    end
    assert_equal 'blockdata 1 2 3 {auto:1}', commands[-1]
  end
end
