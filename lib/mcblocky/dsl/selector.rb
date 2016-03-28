module McBlocky::DSL
  class Selector
    def initialize(name, **kwargs)
      @name = name
      if kwargs[:loc]
        loc = kwargs[:loc]
        raise ArgumentError, "Relative locations are not allowed in selectors" if loc.is_relative?
        kwargs[:x] = loc.x
        kwargs[:y] = loc.y
        kwargs[:z] = loc.z
        kwargs.delete :loc
      end
      @args = kwargs
    end

    def [](**args)
      Selector.new(@name, @args.merge(args))
    end

    def to_s
      if @args.empty?
        @name
      else
        pairs = @args.map{|k,v| "#{k}=#{v}"}
        "#{@name}[#{pairs.join(',')}]"
      end
    end
  end
end
