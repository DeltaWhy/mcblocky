require 'test_helper'

class SelectorTest < Minitest::Test
  def setup
    @a = McBlocky::DSL::Selector.new '@a'
    @e = McBlocky::DSL::Selector.new '@e'
    @p = McBlocky::DSL::Selector.new '@p'
    @r = McBlocky::DSL::Selector.new '@r'
  end

  def test_bare_selector
    assert_equal '@a', @a.to_s
    assert_equal '@e', @e.to_s
  end

  def test_selector_with_args
    assert_equal '@a[team=Red]', @a[team: 'Red'].to_s
    assert_equal '@e[x=1,y=2,z=3,r=1]', @e[x: 1, y: 2, z: 3, r: 1].to_s
  end
end
