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

      #old_ats = old_context ? old_context.chains.select{|x|x.kind == :at} : []
      #ats = context.chains.select{|x|x.kind == :at}

      locations = (old_context ? old_context.blocks.keys : []) + context.blocks.keys
      locations.uniq.each do |loc|
        old = old_context ? old_context.blocks[loc] : nil
        new = context.blocks[loc]
        do_block(new, old)
      end

      # after blocks are set
      context.chains.select{|x|x.kind == :after}.each do |c|
        p c.commands
        self.commands += c.commands
      end
    end

    def do_block(block, old_block=nil)
      if old_block and !block
        setblock old_block.x, old_block.y, old_block.z, 'minecraft:air'
        return
      end

      p block.nbt
      if old_block and old_block.block_kind == block.block_kind and old_block.block_data == block.block_data
        return if old_block.nbt == block.nbt
        blockdata block.x, block.y, block.z, block.nbt
      else
        setblock block.x, block.y, block.z, block.block_kind, block.block_data, 'replace'
        blockdata block.x, block.y, block.z, block.nbt
      end
    end
  end
end
