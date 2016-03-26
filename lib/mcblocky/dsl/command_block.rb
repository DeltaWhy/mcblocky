module McBlocky::DSL
  class CommandBlock < Commands
    attr_reader :x, :y, :z, :block_data, :block_kind
    def initialize(x, y, z, facing, kind)
      super(:at)
      @x = x
      @y = y
      @z = z
      @block_data = facing
      @block_kind = kind
    end

    def command(*args)
      raise ArgumentError, "Only one command is allowed per block" unless commands.empty?
      super
    end

    def nbt
      return {'Command'=>commands[0] || ''}
    end
  end
end
