require 'test_helper'

class McBlockyTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::McBlocky::VERSION
  end
end
