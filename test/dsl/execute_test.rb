require 'test_helper'

class ExecuteTest < Minitest::Test
  def test_execute_without_block
    commands = assert_valid do
      initial do
        execute @p[score_GAME_min:1], '~ ~ ~', 'scoreboard objectives setdisplay sidebar Score'
      end
    end
    assert_equal [
      'execute @p[score_GAME_min=1] ~ ~ ~ scoreboard objectives setdisplay sidebar Score'
    ], commands
  end

  def test_execute_block_without_location
    commands = assert_valid do
      initial do
        execute @p[score_GAME_min:1] do
          scoreboard :objectives, :setdisplay, :sidebar, 'Score'
          setblock 0, 34, 12, 'minecraft:standing_banner', 12
        end
      end
    end
    assert_equal [
      'execute @p[score_GAME_min=1] ~ ~ ~ scoreboard objectives setdisplay sidebar Score',
      'execute @p[score_GAME_min=1] ~ ~ ~ setblock 0 34 12 minecraft:standing_banner 12'
    ], commands
  end

  def test_execute_block_with_location
    commands = assert_valid do
      initial do
        execute @p, '~ ~-1 ~' do
          say 'foo'
          say 'bar'
        end
      end
    end
    assert_equal [
      'execute @p ~ ~-1 ~ say foo',
      'execute @p ~ ~-1 ~ say bar'
    ], commands
  end
end
