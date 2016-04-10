require 'test_helper'

class AreaTest < Minitest::Test
  def test_area
    commands = assert_valid do
      area 1, 2, 3, 10, 10, 10
      repeat do
        say 'Hello'
        say 'there'
        say 'world'
      end
      chain :foo do
        say 'foo'
      end
      repeat do
        say 'blah'
      end
    end

    # impulse chains get an extra command
    assert_equal 12, commands.length

    # ensure all positions are unique and valid
    positions = Set.new
    p commands
    commands.each do |c|
      next if c.start_with? 'blockdata'
      _, x, y, z = c.split
      x, y, z = x.to_i, y.to_i, z.to_i
      assert x >= 1 and x <= 10
      assert y >= 2 and y <= 10
      assert z >= 3 and z <= 10
      assert !positions.include?("#{x} #{y} #{z}")
      positions.add "#{x} #{y} #{z}"
    end
  end
end
