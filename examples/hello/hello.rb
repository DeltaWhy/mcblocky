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
  scoreboard :objectives do
    add 'SwitchingTeam', 'dummy'
  end

  tellraw @a[team: 'Red'], {text: "Hello world", color: "red"}
end

repeat :teams, 171, 82, 242, 175, 84, 242 do
  scoreboard :players, :set, @a[x: 172, y: 81, z: 236, r: 1, team: '!Red'], 'SwitchingTeam', 1
  scoreboard :players, :set, @a[x: 170, y: 81, z: 236, r: 1, team: '!Blue'], 'SwitchingTeam', 1
  execute @a[x: 170, y: 81, z: 236, r: 1, score_SwitchingTeam_min: 1], '~ ~ ~', 'scoreboard teams join Blue @p'
  execute @a[x: 170, y: 81, z: 236, r: 1, score_SwitchingTeam_min: 1], '~ ~ ~', :tellraw, @a, JSON.dump([
    {selector: @p},
    {text: ' joined the ', color: 'reset'},
    {text: 'Blue', color: 'blue'},
    {text: ' team', color: 'reset'}
  ])
  execute @a[x: 172, y: 81, z: 236, r: 1, score_SwitchingTeam_min: 1], '~ ~ ~', 'scoreboard teams join Red @p'
  execute @a[x: 172, y: 81, z: 236, r: 1, score_SwitchingTeam_min: 1], '~ ~ ~', :tellraw, @a, JSON.dump([
    {selector: @p},
    {text: ' joined the ', color: 'reset'},
    {text: 'Red', color: 'red'},
    {text: ' team', color: 'reset'}
  ])
  scoreboard :players, :reset, @a[score_SwitchingTeam_min: 1], 'SwitchingTeam'
  #tellraw @a[team: 'Red'], {text: "Hello", color: "red"}
end

fill 171, 78, 242, 181, 78, 252, 'minecraft:stained_glass', Color::BLUE

cleanup do
  fill 172, 80, 243, 174, 80, 243, 'minecraft:air', 0, 'replace'
end

at 172, 79, 243 do
  fill '~', '~1', '~', '~2', '~1', '~', 'minecraft:stone'
end

at 172, 81, 243 do
  fill '~ ~-1 ~ ~2 ~-1 ~', 'minecraft:redstone_block'
end

setblock 175, 79, 248, 'minecraft:standing_sign', 0, 'replace', {'Text1'=>'{"text":"hello friends"}'}

furnace 176, 79, 248 do
  item 'minecraft:diamond', 64
  item 'minecraft:spawn_egg', 1, 0, {'EntityTag'=>{'id'=>'Chicken', 'CustomName'=>'Chickfila'}, 'display'=>{'Name'=>'Chicken Egg'}}
  item 'minecraft:gold_ingot'
end

at 172, 79, 244 do
  disable :teams
end

at 174, 79, 244 do
  enable :teams
end

setblock 172, 80, 244, 'minecraft:standing_sign', 0, 'replace', {'Text1'=>'{"text":"Disable team"}', 'Text2'=>'{"text":"switcher"}'}
setblock 174, 80, 244, 'minecraft:standing_sign', 0, 'replace', {'Text1'=>'{"text":"Enable team"}', 'Text2'=>'{"text":"switcher"}'}
setblock 172, 79, 245, 'minecraft:stone_button', 3
setblock 174, 79, 245, 'minecraft:stone_button', 3

chain :hello, 171, 82, 243, 175, 84, 243 do
  say 'Hello'
  say 'World'
end

at 176, 79, 244 do
  activate :hello
end

setblock 176, 80, 244, 'minecraft:standing_sign', 0, 'replace', {'Text1'=>'{"text":"Activate hello"}'}
setblock 176, 79, 245, 'minecraft:stone_button', 3

after do
  # setblock 175, 79, 248, 'minecraft:standing_sign', 0, 'replace'
  # blockdata 175, 79, 248, {'Text1'=>'{"text":"hola mundo"}'}
  setblock 172, 80, 243, 'minecraft:redstone_block', 0, 'replace'
end
