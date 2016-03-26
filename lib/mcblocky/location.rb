module McBlocky
  class Location < Struct.new(:x, :y, :z)
    def +(other)
      if other.is_relative?
        Location.new(x + other.x, y + other.y, z + other.z)
      else
        RelativeLocation.new(x + other.x, y + other.y, z + other.z)
      end
    end

    def -(other)
      if other.is_relative?
        Location.new(x - other.x, y - other.y, z - other.z)
      else
        RelativeLocation.new(x - other.x, y - other.y, z - other.z)
      end
    end

    def is_relative?
      false
    end
  end

  class RelativeLocation < Location
    def +(other)
      if other.is_relative?
        RelativeLocation.new(x + other.x, y + other.y, z + other.z)
      else
        Location.new(x + other.x, y + other.y, z + other.z)
      end
    end

    def -(other)
      if other.is_relative?
        RelativeLocation.new(x - other.x, y - other.y, z - other.z)
      else
        Location.new(x - other.x, y - other.y, z - other.z)
      end
    end

    def is_relative?
      true
    end
  end
end
