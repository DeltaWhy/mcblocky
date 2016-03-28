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

  def test_partial_selector
    p = @a[x: 1, y: 2, z: 3, r: 1]
    assert_equal '@a[x=1,y=2,z=3,r=1]', p.to_s
    assert_equal '@a[x=1,y=2,z=3,r=1,team=Blue]', p[team: 'Blue'].to_s
    assert_equal '@a[x=1,y=2,z=3,r=1,team=Red]', p[team: 'Red'].to_s
  end

  def test_location_selector
    l = McBlocky::Location.new(1, 2, 3)
    assert_equal '@a[r=1,x=1,y=2,z=3]', @a[loc: l, r: 1].to_s
  end

  def test_selector_rejects_relative_location
    l = McBlocky::RelativeLocation.new(0, 1, 0)
    assert_raises(ArgumentError) {
      @a[loc: l]
    }
  end
end
