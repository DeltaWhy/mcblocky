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

  class Rect < Struct.new(:x1, :y1, :z1, :x2, :y2, :z2)
    def initialize(*args)
      if args.length == 6
        super
      elsif args.length == 2
        super(args[0].x, args[0].y, args[0].z, args[1].x, args[1].y, args[1].z)
      elsif args.length == 4
        if args[0].respond_to? :x
          super(args[0].x, args[0].y, args[0].z, args[1], args[2], args[3])
        elsif args[3].respond_to? :x
          super(args[0], args[1], args[2], args[3].x, args[3].y, args[3].z)
        else
          raise ArgumentError
        end
      else
        raise ArgumentError
      end

      if x1 > x2
        self.x1, self.x2 = self.x2, self.x1
      end
      if y1 > y2
        self.y1, self.y2 = self.y2, self.y1
      end
      if z1 > z2
        self.z1, self.z2 = self.z2, self.z1
      end
    end
  end
end
