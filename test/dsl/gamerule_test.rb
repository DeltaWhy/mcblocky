require 'test_helper'

class GameruleTest < Minitest::Test
  def test_that_it_accepts_valid_arguments
    commands = assert_valid do
      initial do
        gamerule :doDaylightCycle, false
      end
    end
    assert_equal ['gamerule doDaylightCycle false'], commands
  end

  def test_that_it_rejects_missing_value
    assert_invalid do
      initial do
        gamerule :doDaylightCycle
      end
    end
  end

  def test_that_it_accepts_block
    commands = assert_valid do
      initial do
        gamerule do
          doDaylightCycle false
          logAdminCommands false
        end
      end
    end
    assert_equal [
      'gamerule doDaylightCycle false',
      'gamerule logAdminCommands false'
    ], commands
  end

  def test_that_it_rejects_block_with_arguments
    assert_invalid do
      initial do
        gamerule :doDaylightCycle do
          # do nothing
        end
      end
    end
  end
end
