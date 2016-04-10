module McBlocky::DSL
  class ImpulseChain < Commands
    attr_reader :rect
    def initialize(context, *args)
      super(context, :impulse_chain)
      @rect = McBlocky::Rect.new(*args)
    end
  end
end
