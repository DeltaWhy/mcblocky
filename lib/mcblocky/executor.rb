module McBlocky
  class Executor
    def self.to_commands(context, old_context=nil)
      commands = []
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
              commands << cmd
            else
              commands << cmd
            end
          end
        else
          chain.commands.each {|cmd| commands << cmd}
        end
      end

      if old_context
        old_context.areas.each do |x1, y1, z1, x2, y2, z2|
          commands << ['fill', x1, y1, z1, x2, y2, z2, 'minecraft:air'].join(' ')
        end
      end
      context.areas.each do |x1, y1, z1, x2, y2, z2|
        commands << ['fill', x1, y1, z1, x2, y1, z2, 'minecraft:stained_glass', '7'].join(' ')
        commands << ['fill', x1, y2, z1, x2, y2, z2, 'minecraft:stained_glass', '7'].join(' ')
        commands << ['fill', x1, y1, z1, x1, y2, z2, 'minecraft:stained_glass', '7'].join(' ')
        commands << ['fill', x2, y1, z1, x2, y2, z2, 'minecraft:stained_glass', '7'].join(' ')
        commands << ['fill', x1, y1, z1, x2, y2, z1, 'minecraft:stained_glass', '7'].join(' ')
        commands << ['fill', x1, y1, z2, x2, y2, z2, 'minecraft:stained_glass', '7'].join(' ')
      end

      return commands
    end
  end
end
