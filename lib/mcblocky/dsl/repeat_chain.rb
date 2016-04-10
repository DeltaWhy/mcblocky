module McBlocky::DSL
  class RepeatChain < Commands
    attr_reader :rect
    def initialize(context, *args)
      super(context, :repeat)
      @rect = McBlocky::Rect.new(*args)
    end
  end
end
