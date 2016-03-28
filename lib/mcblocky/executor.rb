module McBlocky
  class Executor < DSL::Commands
    def self.to_commands(context, old_context=nil)
      executor = Executor.new(:final)
      executor.do_context(context, old_context)
      executor.commands
    end

    def do_context(context, old_context)
      # do cleanup first
      if old_context
        old_context.chains.select{|x|x.kind == :cleanup}.each do |c|
          self.commands += c.commands
        end
      end

      # do initial blocks
      old_initials = old_context ? old_context.chains.select{|x|x.kind == :initial} : []
      initials = context.chains.select{|x|x.kind == :initial}
      initials.each_with_index do |chain, i|
        old_chain = old_initials[i]
        if old_chain
          matches = true
          chain.commands.each_with_index do |cmd, j|
            if matches
              old_cmd = old_chain.commands[j]
              next if old_cmd == cmd
              matches = false
              command cmd
            else
              command cmd
            end
          end
        else
          chain.commands.each {|cmd| command cmd}
        end
      end

      if old_context
        old_context.areas.each do |x1, y1, z1, x2, y2, z2|
          fill x1, y1, z1, x2, y2, z2, 'minecraft:air'
        end
      end
      context.areas.each do |x1, y1, z1, x2, y2, z2|
        fill x1, y1, z1, x2, y1, z2, 'minecraft:stained_glass', '7'
        fill x1, y2, z1, x2, y2, z2, 'minecraft:stained_glass', '7'
        fill x1, y1, z1, x1, y2, z2, 'minecraft:stained_glass', '7'
        fill x2, y1, z1, x2, y2, z2, 'minecraft:stained_glass', '7'
        fill x1, y1, z1, x2, y2, z1, 'minecraft:stained_glass', '7'
        fill x1, y1, z2, x2, y2, z2, 'minecraft:stained_glass', '7'
      end

      rects = (old_context ? old_context.rects.keys : []) + context.rects.keys
      rects.uniq.each do |rect|
        old_block = old_context ? old_context.rects[rect] : nil
        block = context.rects[rect]
        if old_block and !block
          fill rect.x1, rect.y1, rect.z1, rect.x2, rect.y2, rect.z2, 'minecraft:air'
        elsif old_block and old_block != block
          fill rect.x1, rect.y1, rect.z1, rect.x2, rect.y2, rect.z2, block.block_kind, block.block_data, 'replace', old_block.block_kind, old_block.block_data
        else
          fill rect.x1, rect.y1, rect.z1, rect.x2, rect.y2, rect.z2, block.block_kind, block.block_data
        end
      end

      context.chains.select{|x|x.kind == :repeat}.each do |c|
        do_repeat context, c
      end

      locations = (old_context ? old_context.blocks.keys : []) + context.blocks.keys
      locations.uniq.each do |loc|
        old = old_context ? old_context.blocks[loc] : nil
        new = context.blocks[loc]
        do_block(new, old)
      end

      # after blocks are set
      context.chains.select{|x|x.kind == :after}.each do |c|
        self.commands += c.commands
      end
    end

    def do_block(block, old_block=nil)
      if old_block and !block
        setblock old_block.x, old_block.y, old_block.z, 'minecraft:air'
        return
      end

      if old_block and old_block.block_kind == block.block_kind and old_block.block_data == block.block_data
        return if old_block.nbt == block.nbt
        blockdata block.x, block.y, block.z, block.nbt unless block.nbt == {}
      else
        setblock block.x, block.y, block.z, block.block_kind, block.block_data, 'replace'
        blockdata block.x, block.y, block.z, block.nbt unless block.nbt == {}
      end
    end

    def do_repeat(context, chain)
      sequence = fill_space(chain.rect)
      if chain.commands.length > sequence.length
        raise ArgumentError, "Chain is too long for the provided space"
      end
      kind = 'minecraft:repeating_command_block'
      chain.commands.each_with_index do |c,i|
        cursor = sequence[i]
        next_cursor = if i+1 < sequence.length
                        sequence[i+1]
                      else
                        Location.new(cursor.x, cursor.y+1, cursor.z)
                      end
        facing = if next_cursor.x - cursor.x == 1
                   DSL::Facing::EAST
                 elsif next_cursor.x - cursor.x == -1
                   DSL::Facing::WEST
                 elsif next_cursor.y - cursor.y == 1
                   DSL::Facing::UP
                 elsif next_cursor.y - cursor.y == -1
                   DSL::Facing::DOWN
                 elsif next_cursor.z - cursor.z == 1
                   DSL::Facing::SOUTH
                 elsif next_cursor.z - cursor.z == -1
                   DSL::Facing::NORTH
                 end
        context.blocks[cursor] = DSL::CommandBlock.new(cursor.x, cursor.y, cursor.z, facing, kind, {'auto'=>1})
        context.blocks[cursor].command c
        kind = 'minecraft:chain_command_block'
      end
    end

    def fill_space(rect)
      path = []
      zrange = rect.z1..rect.z2
      zrange.each do |z|
        rz = z - rect.z1
        yrange = rect.y1..rect.y2
        yrange = yrange.to_a.reverse if rz % 2 != 0
        yrange.each do |y|
          ry = y - rect.y1
          xrange = rect.x1..rect.x2
          xrange = xrange.to_a.reverse if (ry+rz) % 2 != 0
          xrange.each do |x|
            path << Location.new(x, y, z)
          end
        end
      end
      path
    end
  end
end
