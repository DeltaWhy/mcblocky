module McBlocky::DSL
  class Container
    attr_reader :x, :y, :z, :block_data, :block_kind, :nbt
    def initialize(x, y, z, kind, data=0, nbt={})
      @x = x
      @y = y
      @z = z
      @block_kind = kind
      @block_data = data
      @nbt = nbt
      @last_slot = -1
    end

    def item_in_slot(slot, kind, count=1, damage=0, tag={})
      nbt['Items'] ||= []
      nbt['Items'] << {'Slot'=>slot, 'id'=>kind, 'Count'=>count, 'Damage'=>damage, 'tag'=>tag}
      @last_slot = slot if slot > @last_slot
    end

    def item(kind, count=1, damage=0, tag={})
      item_in_slot(@last_slot+1, kind, count, damage, tag)
    end
  end
end
