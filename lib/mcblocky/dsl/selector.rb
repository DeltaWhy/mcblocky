module McBlocky::DSL
  class Selector
    def initialize(name)
      @name = name
    end

    def [](**args)
      pairs = args.map{|k,v| "#{k}=#{v}"}
      "#{@name}[#{pairs.join(',')}]"
    end

    def to_s
      @name
    end
  end
end
