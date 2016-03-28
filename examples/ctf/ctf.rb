# Capture the Flag
#
# Made for 1.9 void world preset

red_spawn = Location.new(0, 34, 12)
blue_spawn = Location.new(50, 34, 12)

helper 'clean' do |args, user|
  Executor.to_commands($context).each{|c| server.command c}
end

helper 'blue' do |args, user|
  user = user.gsub(/[^A-Za-z0-9_]./, '')
  server.command "scoreboard teams join Blue #{user}"
end

helper 'red' do |args, user|
  user = user.gsub(/[^A-Za-z0-9_]./, '')
  server.command "scoreboard teams join Red #{user}"
end

helper 'reset' do |args, user|
  server.command "scoreboard players set @a GAME 1"
end

initial do
  time :set, 'day'
  gamerule :doDaylightCycle, false
  gamerule :logAdminCommands, false
  gamerule :commandBlockOutput, false
  weather :clear, 999999

  scoreboard :teams do
    add 'Red'
    option 'Red', :color, 'red'
    add 'Blue'
    option 'Blue', :color, 'blue'
    join 'Red', '--RED--'
    join 'Blue', '--BLUE--'
    add 'Spectators'
  end

  scoreboard :objectives do
    add 'LOGIN', :dummy
    add 'GAME', :dummy
    add 'SwitchingTeam', :dummy
    add 'Score', :dummy
    add 'CapturingFlag', :dummy
    add 'CapturingOwnFlag', :dummy
    add 'HasFlag', :dummy
    add 'HasOwnFlag', :dummy
    add 'ReturningFlag', :dummy
    add 'ReturningOwnFlag', :dummy
    add 'IsDead', :deathCount
  end
end

# login
repeat -8, 6, -8, 8, 8, -8 do
  scoreboard :players, :add, @a, 'LOGIN', 0
  tp @a[score_LOGIN:0], -95, 33, -95
  clear @a[score_LOGIN:0]
  scoreboard :teams, :join, 'Spectators', @a[score_LOGIN:0]
  tellraw @a[score_LOGIN:0], [
    {text: "Welcome to ", color: "gold"},
    {text: "McBlocky ", color: "aqua"},
    {text: "C", color: "red"},
    {text: "T", color: "green"},
    {text: "F", color: "blue"},
    {text: "!", color: "gold"}
  ]
  scoreboard :players, :set, @a[score_LOGIN:0], 'LOGIN', 1
end

# room construction
require_relative 'arena'
require_relative 'lobby'

# team join/leave
repeat 10, 6, -8, 24, 8, -8 do
  scoreboard :players do
    set @a[team: '!Red', x: -95, y: 33, z: -102, r:4], 'SwitchingTeam', 1
    set @a[team: '!Blue', x: -95, y: 33, z: -88, r:4], 'SwitchingTeam', 1
    set @a[team: '!Spectators', x: -102, y: 33, z: -95, r: 4], 'SwitchingTeam', 1
  end
  scoreboard :teams do
    join 'Red', @a[team: '!Red', x: -95, y: 33, z: -102, r:4]
    join 'Blue', @a[team: '!Blue', x: -95, y: 33, z: -88, r:4]
    join 'Spectators', @a[team: '!Spectators', x: -102, y: 33, z: -95, r: 4]
  end
  execute @a[score_SwitchingTeam_min:1, team: 'Red'] do
    tellraw @a, {selector: "@p"},
      {text: " joined the ", color: "reset"},
      {text: "Red", color: "red"},
      {text: " team", color: "reset"}
  end
  execute @a[score_SwitchingTeam_min:1, team: 'Blue'] do
    tellraw @a, {selector: "@p"},
      {text: " joined the ", color: "reset"},
      {text: "Blue", color: "blue"},
      {text: " team", color: "reset"}
  end
  execute @a[score_SwitchingTeam_min:1, team: 'Spectators'] do
    tellraw @a, {selector: "@p"},
      {text: " is now spectating", color: "reset"}
  end
  scoreboard :players, :reset, @a[score_SwitchingTeam_min:1], 'SwitchingTeam'
end

# game start
repeat -8, 6, -6, 8, 8, -6 do
  a = @a[score_GAME_min:1]
  p = @p[score_GAME_min:1]

  gamemode 3, a[team:'Spectators']
  gamemode 2, a[team:'!Spectators']
  tp a[team:'Red'], 0, 34, 12, 270, 0
  tp a[team:'Blue'], 50, 34, 12, 90, 0
  tp a[team:'Spectators'], 25, 38, 12
  clear a
  replaceitem :entity, a[team:'Red'], 'slot.armor.chest', 'minecraft:leather_chestplate', 1, 0, {display:{color:10040115}}
  replaceitem :entity, a[team:'Blue'], 'slot.armor.chest', 'minecraft:leather_chestplate', 1, 0, {display:{color:3361970}}

  execute p do
    scoreboard :objectives, :setdisplay, :sidebar, 'Score'
    fill 0, 34, 0, 50, 36, 24, 'minecraft:air', 0, :replace, 'minecraft:standing_banner'
    setblock 0, 34, 12, 'minecraft:standing_banner', 12
    blockdata 0, 34, 12, {'Base'=>1}
    setblock 50, 34, 12, 'minecraft:standing_banner', 4
    blockdata 50, 34, 12, {'Base'=>4}
    %w(HasFlag HasOwnFlag CapturingFlag CapturingOwnFlag ReturningFlag ReturningOwnFlag).each do |s|
      scoreboard :players, :reset, @a, s
    end
    scoreboard :players, :reset, '*', 'Score'
    scoreboard :players, :set, '--RED--', 'Score', 0
    scoreboard :players, :set, '--BLUE--', 'Score', 0
  end

  effect a, 'minecraft:saturation', 1, 99
  effect a, 'minecraft:instant_health', 1, 99
  spawnpoint a[team:'Red'], 0, 34, 12
  spawnpoint a[team:'Blue'], 50, 34, 12
  scoreboard :players, :reset, @a, 'GAME'
end

# pick up enemy flag
repeat 10, 6, -6, 24, 8, -6 do
  execute @a[team:'Red'], '~ ~ ~', :detect, '~ ~ ~', 'minecraft:standing_banner', 4, 'scoreboard players set @p CapturingFlag 1'
  execute @a[team:'Blue'], '~ ~ ~', :detect, '~ ~ ~', 'minecraft:standing_banner', 12, 'scoreboard players set @p CapturingFlag 1'
  red = @p[team:'Red', score_CapturingFlag_min:1]
  blue = @p[team:'Blue', score_CapturingFlag_min:1]

  execute red do
    tellraw @a, {selector: "@p"},
      {text: " got the ", color: "reset"},
      {text: "Blue Flag", color: "blue"}
  end
  replaceitem :entity, red, 'slot.armor.head', 'minecraft:banner', 1, 4
  execute blue do
    tellraw @a, {selector: "@p"},
      {text: " got the ", color: "reset"},
      {text: "Red Flag", color: "red"}
  end
  replaceitem :entity, blue, 'slot.armor.head', 'minecraft:banner', 1, 1

  execute @a[score_CapturingFlag_min:1] do
    setblock '~ ~ ~', 'minecraft:air'
    scoreboard :players, :set, @p, 'HasFlag', 1
    scoreboard :players, :reset, @p, 'CapturingFlag'
  end
end

# capture enemy flag
repeat -8, 6, -4, 8, 8, -4 do
  execute @p[team:'Red', score_HasFlag_min:1, loc: red_spawn, r: 1], '~ ~ ~', :detect, '~ ~ ~', 'minecraft:standing_banner', 12 do
    scoreboard :players, :set, @p, 'ReturningFlag', 1
  end
  execute @p[team:'Blue', score_HasFlag_min:1, loc: blue_spawn, r: 1], '~ ~ ~', :detect, '~ ~ ~', 'minecraft:standing_banner', 4 do
    scoreboard :players, :set, @p, 'ReturningFlag', 1
  end
  red = @p[team:'Red', score_ReturningFlag_min:1]
  blue = @p[team:'Blue', score_ReturningFlag_min:1]

  execute red do
    title @a, :title, {text: "Score", color: "red"}
    title @a, :subtitle,
      {selector: "@p"},
      {text: " captured the flag", color: "reset"}
  end

  execute blue do
    title @a, :title, {text: "Score", color: "blue"}
    title @a, :subtitle,
      {selector: "@p"},
      {text: " captured the flag", color: "reset"}
  end

  # reset the flag
  execute red do
    setblock 50, 34, 12, 'minecraft:standing_banner', 4
    blockdata 50, 34, 12, {'Base'=>4}
  end
  execute blue do
    setblock 0, 34, 12, 'minecraft:standing_banner', 12
    blockdata 0, 34, 12, {'Base'=>1}
  end
  replaceitem :entity, @a[score_ReturningFlag_min:1], 'slot.armor.head', 'minecraft:air'

  # scores
  execute red do
    scoreboard :players, :add, '--RED--', 'Score', 1
  end
  execute blue do
    scoreboard :players, :add, '--BLUE--', 'Score', 1
  end
  scoreboard :players, :add, @a[score_ReturningFlag_min:1], 'Score', 1
  execute @a[score_ReturningFlag_min:1] do
    scoreboard :players, :reset, @p, 'HasFlag'
    scoreboard :players, :reset, @p, 'ReturningFlag'
  end
end

# drop flag on death
repeat 10, 6, -4, 24, 8, -4 do
  # only @a includes dead players
  red = @a[score_IsDead_min:1, score_HasFlag_min:1, team: 'Red']
  blue = @a[score_IsDead_min:1, score_HasFlag_min:1, team: 'Blue']

  execute red do
    tellraw @a, {selector: red},
      {text: " dropped the ", color: "reset"},
      {text: "Blue Flag", color: "blue"}
  end
  execute blue do
    tellraw @a, {selector: blue},
      {text: " dropped the ", color: "reset"},
      {text: "Red Flag", color: "red"}
  end
  execute red do
    setblock '~ ~ ~', 'minecraft:standing_banner', 4
    blockdata '~ ~ ~', {'Base'=>4}
  end
  execute blue do
    setblock '~ ~ ~', 'minecraft:standing_banner', 12
    blockdata '~ ~ ~', {'Base'=>1}
  end

  scoreboard :players, :reset, @a[score_IsDead_min:1], 'HasFlag'
  scoreboard :players, :reset, @a[score_IsDead_min:1], 'HasOwnFlag'
  scoreboard :players, :reset, @a[score_IsDead_min:1], 'IsDead'
end

# pick up own flag
repeat -8, 6, -2, 8, 8, -2 do
  execute @a[team:'Blue'], '~ ~ ~', :detect, '~ ~ ~', 'minecraft:standing_banner', 4, 'scoreboard players set @p CapturingOwnFlag 1'
  execute @a[team:'Red'], '~ ~ ~', :detect, '~ ~ ~', 'minecraft:standing_banner', 12, 'scoreboard players set @p CapturingOwnFlag 1'
  # can't pick up own flag when it's at base
  execute @a[score_CapturingOwnFlag_min:1], '~ ~ ~', :detect, '~ ~-1 ~', 'minecraft:gold_block', 0, 'scoreboard players reset @p CapturingOwnFlag'
  blue = @p[team:'Blue', score_CapturingOwnFlag_min:1]
  red = @p[team:'Red', score_CapturingOwnFlag_min:1]

  execute blue do
    tellraw @a, {selector: "@p"},
      {text: " got the ", color: "reset"},
      {text: "Blue Flag", color: "blue"}
  end
  replaceitem :entity, blue, 'slot.armor.head', 'minecraft:banner', 1, 4
  execute red do
    tellraw @a, {selector: "@p"},
      {text: " got the ", color: "reset"},
      {text: "Red Flag", color: "red"}
  end
  replaceitem :entity, red, 'slot.armor.head', 'minecraft:banner', 1, 1
  execute @a[score_CapturingOwnFlag_min:1] do
    setblock '~ ~ ~', 'minecraft:air'
    scoreboard :players, :set, @p, 'HasOwnFlag', 1
    scoreboard :players, :reset, @p, 'CapturingOwnFlag'
   end
end

# return own flag
repeat 10, 6, -2, 24, 8, -2 do
  execute @a[team:'Blue', loc: blue_spawn, r: 1, score_HasOwnFlag_min: 1] do
    scoreboard :players, :set, @p, 'ReturningOwnFlag', 1
  end
  execute @a[team:'Red', loc: red_spawn, r: 1, score_HasOwnFlag_min: 1] do
    scoreboard :players, :set, @p, 'ReturningOwnFlag', 1
  end
  execute @a[team:'Blue',score_ReturningOwnFlag_min:1] do
    setblock 50, 34, 12, 'minecraft:standing_banner', 4
    blockdata 50, 34, 12, {'Base'=>4}
    tellraw @a, {selector: "@p"},
      {text: " returned the ", color: "reset"},
      {text: "Blue Flag", color: "blue"}
  end
  execute @a[team:'Red',score_ReturningOwnFlag_min:1] do
    setblock 0, 34, 12, 'minecraft:standing_banner', 12
    blockdata 0, 34, 12, {'Base'=>1}
    tellraw @a, {selector: "@p"},
      {text: " returned the ", color: "reset"},
      {text: "Red Flag", color: "red"}
  end
  replaceitem :entity, @a[score_ReturningOwnFlag_min:1], 'slot.armor.head', 'minecraft:air'
  scoreboard :players, :reset, @a[score_ReturningOwnFlag_min:1], 'HasOwnFlag'
  scoreboard :players, :reset, @a[score_ReturningOwnFlag_min:1], 'ReturningOwnFlag'
end
