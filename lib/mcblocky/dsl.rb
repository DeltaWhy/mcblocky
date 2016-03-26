load File.expand_path('dsl/selector.rb', File.dirname(__FILE__))
load File.expand_path('dsl/commands.rb', File.dirname(__FILE__))
load File.expand_path('dsl/command_block.rb', File.dirname(__FILE__))
load File.expand_path('dsl/block.rb', File.dirname(__FILE__))
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

    def at(x, y, z, kind=:normal, &block)
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
      cblock = CommandBlock.new(x, y, z, 0, block_kind)
      cblock.instance_exec(&block)
      blocks[Location.new(x, y, z)] = cblock
    end

    def setblock(x, y, z, kind, data=0, replacemode='replace', nbt={})
      block = Block.new(x, y, z, kind, data, nbt)
      blocks[Location.new(x, y, z)] = block
    end

    def to_nbt(obj)
      case obj
      when String
        JSON.dump(obj)
      when Fixnum, Float
        obj.to_s
      when Array
        "[#{obj.map(method(:to_nbt)).join(',')}]"
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
  end
end
