module McBlocky::DSL
  class RepeatChain < Commands
    attr_reader :rect
    def initialize(*args)
      super(:repeat)
      @rect = McBlocky::Rect.new(*args)
    end
  end
end
