require_relative 'helpers/foo'

helper 'hello' do |args, user|
  server.say "Hello, #{user}!"
end

helper 'clean' do |args, user|
  Executor.to_commands($context).each{|c| server.command c}
end

initial do
  gamerule 'doDaylightCycle', false
  gamerule 'commandBlockOutput', false
  gamerule 'logAdminCommands', false
  time :set, 'day'

  ['red', 'blue', 'yellow', 'green'].each do |color|
    scoreboard :teams do
      add color.capitalize
      option color.capitalize, :color, color
    end
  end
  scoreboard :teams do
    add 'Spectators'
    option 'Spectators', :color, 'gray'
  end

  tellraw @a[team: 'Red'], {text: "Hello world", color: "red"}
end

# area 171, 78, 242, 181, 83, 252 do
#   repeat do
#     tellraw @a[team: 'Red'], {text: "Hello", color: "red"}
#   end
# end

cleanup do
  fill 172, 80, 243, 174, 80, 243, 'minecraft:air', 0, 'replace'
end

at 172, 79, 243 do
  fill '~', '~1', '~', '~2', '~1', '~', 'minecraft:stone'
end

at 172, 81, 243 do
  fill '~ ~-1 ~ ~2 ~-1 ~', 'minecraft:redstone_block'
end

after do
  setblock 172, 80, 243, 'minecraft:redstone_block', 0, 'replace'
end
