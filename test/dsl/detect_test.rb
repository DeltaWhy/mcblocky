require 'test_helper'

class DetectTest < Minitest::Test
  def test_detect_without_block
    commands = assert_valid do
      initial do
        detect @p[score_GAME_min:1], '~ ~ ~', 'minecraft:gold_block', 0, 'scoreboard objectives setdisplay sidebar Score'
      end
    end
    assert_equal [
      'execute @p[score_GAME_min=1] ~ ~ ~ detect ~ ~ ~ minecraft:gold_block 0 scoreboard objectives setdisplay sidebar Score'
    ], commands
  end

  def test_detect_block
    commands = assert_valid do
      initial do
        detect @p, '~ ~-1 ~', 'minecraft:gold_block', 0 do
          say 'foo'
          say 'bar'
        end
      end
    end
    assert_equal [
      'execute @p ~ ~ ~ detect ~ ~-1 ~ minecraft:gold_block 0 say foo',
      'execute @p ~ ~ ~ detect ~ ~-1 ~ minecraft:gold_block 0 say bar'
    ], commands
  end
end
