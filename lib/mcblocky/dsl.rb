load File.expand_path('dsl/selector.rb', File.dirname(__FILE__))
load File.expand_path('dsl/commands.rb', File.dirname(__FILE__))
load File.expand_path('dsl/command_block.rb', File.dirname(__FILE__))
load File.expand_path('dsl/block.rb', File.dirname(__FILE__))
load File.expand_path('dsl/container.rb', File.dirname(__FILE__))
require 'json'

module McBlocky
  module DSL
    def helper(*command, &block)
      context.helpers << [command, block]
    end

    def initial(&block)
      chain = Commands.new(:initial)
      chain.instance_exec(&block)
      chains << chain
    end

    def cleanup(&block)
      chain = Commands.new(:cleanup)
      chain.instance_exec(&block)
      chains << chain
    end

    def after(&block)
      chain = Commands.new(:after)
      chain.instance_exec(&block)
      chains << chain
    end

    def repeat(&block)
      chain = Commands.new(:repeat)
      chain.instance_exec(&block)
      chains << chain
    end

    def at(x, y, z, data=0, kind=:normal, &block)
      if Symbol === data
        kind = data
        data = 0
      end
      block_kind = case kind
                   when :normal
                     'minecraft:command_block'
                   when :chain
                     'minecraft:chain_command_block'
                   when :repeating
                     'minecraft:repeating_command_block'
                   else
                     raise ArgumentError, 'Unknown command block type'
                   end
      cblock = CommandBlock.new(x, y, z, data, block_kind)
      cblock.instance_exec(&block)
      blocks[Location.new(x, y, z)] = cblock
    end

    def setblock(x, y, z, kind, data=0, replacemode='replace', nbt={})
      block = Block.new(x, y, z, kind, data, nbt)
      blocks[Location.new(x, y, z)] = block
    end

    def fill(x1, y1, z1, x2, y2, z2, kind, data=0)
      block = Block.new(nil, nil, nil, kind, data)
      rects[Rect.new(x1, y1, z1, x2, y2, z2)] = block
    end

    def chest(x, y, z, data=0, &block)
      container = Container.new(x, y, z, 'minecraft:chest', data)
      container.instance_exec(&block)
      blocks[Location.new(x, y, z)] = container
    end

    def trapped_chest(x, y, z, data=0, &block)
      container = Container.new(x, y, z, 'minecraft:trapped_chest', data)
      container.instance_exec(&block)
      blocks[Location.new(x, y, z)] = container
    end

    def dispenser(x, y, z, data=0, &block)
      container = Container.new(x, y, z, 'minecraft:dispenser', data)
      container.instance_exec(&block)
      blocks[Location.new(x, y, z)] = container
    end

    def dropper(x, y, z, data=0, &block)
      container = Container.new(x, y, z, 'minecraft:dropper', data)
      container.instance_exec(&block)
      blocks[Location.new(x, y, z)] = container
    end

    def furnace(x, y, z, data=0, &block)
      container = Container.new(x, y, z, 'minecraft:furnace', data)
      container.instance_exec(&block)
      blocks[Location.new(x, y, z)] = container
    end

    def to_nbt(obj)
      case obj
      when String
        JSON.dump(obj)
      when Fixnum, Float
        obj.to_s
      when Array
        "[#{obj.map{|x| to_nbt x}.join(',')}]"
      when Hash
        pairs = obj.map do |k,v|
          "#{k}:#{to_nbt v}"
        end
        "{#{pairs.join(',')}}"
      else
        raise ArgumentError, "No NBT form for #{obj}"
      end
    end
    module_function :to_nbt

    module Facing
      DOWN = 0
      UP = 1
      NORTH = 2
      SOUTH = 3
      WEST = 4
      EAST = 5
    end

    module Color
      WHITE = 0
      ORANGE = 1
      MAGENTA = 2
      LIGHT_BLUE = 3
      YELLOW = 4
      LIME = 5
      PINK = 6
      GRAY = 7
      LIGHT_GRAY = 8
      CYAN = 9
      PURPLE = 10
      BLUE = 11
      BROWN = 12
      GREEN = 13
      RED = 14
      BLACK = 15
    end
  end
end
