require 'test_helper'

class AtBlockTest < Minitest::Test
  def test_at_block
    commands = assert_valid do
      at 1, 2, 3 do
        say 'Hello'
      end
    end
    assert_includes commands[0], 'setblock 1 2 3 minecraft:command_block'
    assert_equal 'blockdata 1 2 3 {Command:"say Hello"}', commands[1]
  end

  def test_at_block_args
    commands = assert_valid do
      at 1, 2, 3, :repeating do
        say 'Hello'
      end
    end
    assert_includes commands[0], 'setblock 1 2 3 minecraft:repeating_command_block'

    commands = assert_valid do
      at 1, 2, 3, Facing::UP do
        say 'Hello'
      end
    end
    assert_includes commands[0], "setblock 1 2 3 minecraft:command_block #{Facing::UP}"

    commands = assert_valid do
      at 1, 2, 3, Facing::UP, :chain do
        say 'Hello'
      end
    end
    assert_includes commands[0], "setblock 1 2 3 minecraft:chain_command_block #{Facing::UP}"
  end

  def test_at_block_rejects_partial_args
    assert_invalid do
      at 1, 2 do
        say 'Hello'
      end
    end
  end

  def test_at_block_accepts_location
    skip "Not implemented yet"
    commands = assert_valid do
      l = McBlocky::Location.new(1, 2, 3)
      at l do
        say 'Hello'
      end
    end
    assert_includes commands[0], "setblock 1 2 3"
  end

  def test_at_block_location_with_type
    skip "Not implemented yet"
    l = McBlocky::Location.new(1, 2, 3)
    commands = assert_valid do
      at l, :repeating do
        say 'Hello'
      end
    end
    assert_includes commands[0], 'minecraft:repeating_command_block'

    commands = assert_valid do
      at l, Facing::UP do
        say 'Hello'
      end
    end
    assert_includes commands[0], "minecraft:command_block #{Facing::UP}"

    commands = assert_valid do
      at l, Facing::UP, :chain do
        say 'Hello'
      end
    end
    assert_includes commands[0], "minecraft:chain_command_block #{Facing::UP}"
  end
end
