require 'test_helper'

class ScoreboardTest < Minitest::Test
  def test_scoreboard_block_with_args
    commands = assert_valid do
      initial do
        scoreboard :teams do
          add 'Red'
          option 'Red', :color, 'red'
        end
        scoreboard :objectives do
          add 'Score', :dummy
          setdisplay :sidebar, 'Score'
        end
      end
    end
    assert_equal [
      'scoreboard teams add Red',
      'scoreboard teams option Red color red',
      'scoreboard objectives add Score dummy',
      'scoreboard objectives setdisplay sidebar Score'
    ], commands
  end

  def test_scoreboard_no_block
    commands = assert_valid do
      initial do
        scoreboard :teams, :add, 'Red'
      end
    end
    assert_equal [
      'scoreboard teams add Red'
    ], commands
  end

  def test_scoreboard_block_without_args
    commands = assert_valid do
      initial do
        scoreboard do
          teams :add, 'Red'
          teams :join, 'Red', @a
        end
      end
    end
    assert_equal [
      'scoreboard teams add Red',
      'scoreboard teams join Red @a'
    ], commands
  end

  def test_other_command_in_scoreboard_block
    commands = assert_valid do
      initial do
        scoreboard :teams do
          add 'Red'
          gamerule :seeFriendlyInvisibles, true
        end
      end
    end
    assert_equal [
      'scoreboard teams add Red',
      'gamerule seeFriendlyInvisibles true'
    ], commands
  end
end
