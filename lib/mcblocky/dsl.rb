load File.expand_path('dsl/selector.rb', File.dirname(__FILE__))
load File.expand_path('dsl/commands.rb', File.dirname(__FILE__))
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

    def repeat(&block)
      chain = Commands.new(:repeat)
      chain.instance_exec(&block)
      chains << chain
    end

    def to_nbt(obj)
      case obj
      when String
        "\"#{obj}\""
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
