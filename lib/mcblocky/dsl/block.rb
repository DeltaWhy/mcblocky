module McBlocky::DSL
  class Block
    attr_reader :x, :y, :z, :block_data, :block_kind, :nbt
    def initialize(x, y, z, kind, data=0, nbt={})
      @x = x
      @y = y
      @z = z
      @block_kind = kind
      @block_data = data
      @nbt = nbt
    end
  end
end
