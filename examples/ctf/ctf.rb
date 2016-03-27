# Capture the Flag
#
# Made for 1.9 void world preset

spawn_pad = Rect.new(-8, 4, -8, 24, 4, 24)

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
  scoreboard :players, :set, @a[team: '!Red', x: -95, y: 33, z: -102, r:4], 'SwitchingTeam', 1
  scoreboard :players, :set, @a[team: '!Blue', x: -95, y: 33, z: -88, r:4], 'SwitchingTeam', 1
  scoreboard :players, :set, @a[team: '!Spectators', x: -102, y: 33, z: -95, r: 4], 'SwitchingTeam', 1
  scoreboard :teams, :join, 'Red', @a[team: '!Red', x: -95, y: 33, z: -102, r:4]
  scoreboard :teams, :join, 'Blue', @a[team: '!Blue', x: -95, y: 33, z: -88, r:4]
  scoreboard :teams, :join, 'Spectators', @a[team: '!Spectators', x: -102, y: 33, z: -95, r: 4]
  execute @a[score_SwitchingTeam_min:1, team: 'Red'], '~ ~ ~', :tellraw, @a, JSON.dump([
    {selector: "@p"},
    {text: " joined the ", color: "reset"},
    {text: "Red", color: "red"},
    {text: " team", color: "reset"}
  ])
  execute @a[score_SwitchingTeam_min:1, team: 'Blue'], '~ ~ ~', :tellraw, @a, JSON.dump([
    {selector: "@p"},
    {text: " joined the ", color: "reset"},
    {text: "Blue", color: "blue"},
    {text: " team", color: "reset"}
  ])
  execute @a[score_SwitchingTeam_min:1, team: 'Spectators'], '~ ~ ~', :tellraw, @a, JSON.dump([
    {selector: "@p"},
    {text: " is now spectating", color: "reset"}
  ])
  scoreboard :players, :reset, @a[score_SwitchingTeam_min:1], 'SwitchingTeam'
end

# game start
repeat -8, 6, -6, 8, 8, -6 do
  gamemode 3, @a[score_GAME_min:1, team:'Spectators']
  gamemode 2, @a[score_GAME_min:1, team:'!Spectators']
  tp @a[score_GAME_min:1, team:'Red'], 0, 34, 12, 270, 0
  tp @a[score_GAME_min:1, team:'Blue'], 50, 34, 12, 90, 0
  tp @a[score_GAME_min:1, team:'Spectators'], 25, 38, 12
  clear @a[score_GAME_min:1]
  replaceitem :entity, @a[score_GAME_min:1, team:'Red'], 'slot.armor.chest', 'minecraft:leather_chestplate', 1, 0, {display:{color:10040115}}
  replaceitem :entity, @a[score_GAME_min:1, team:'Blue'], 'slot.armor.chest', 'minecraft:leather_chestplate', 1, 0, {display:{color:3361970}}
  execute @p[score_GAME_min:1], '~ ~ ~', 'scoreboard objectives setdisplay sidebar Score'
  execute @p[score_GAME_min:1], '~ ~ ~', 'fill 0 34 0 50 36 24 minecraft:air 0 replace minecraft:standing_banner'
  execute @p[score_GAME_min:1], '~ ~ ~', 'setblock 0 34 12 minecraft:standing_banner 12'
  execute @p[score_GAME_min:1], '~ ~ ~', 'blockdata 0 34 12 {Base:1}'
  execute @p[score_GAME_min:1], '~ ~ ~', 'setblock 50 34 12 minecraft:standing_banner 4'
  execute @p[score_GAME_min:1], '~ ~ ~', 'blockdata 50 34 12 {Base:4}'
  execute @p[score_GAME_min:1], '~ ~ ~', 'scoreboard players reset @a HasFlag'
  execute @p[score_GAME_min:1], '~ ~ ~', 'scoreboard players reset @a HasOwnFlag'
  execute @p[score_GAME_min:1], '~ ~ ~', 'scoreboard players reset @a CapturingFlag'
  execute @p[score_GAME_min:1], '~ ~ ~', 'scoreboard players reset @a CapturingOwnFlag'
  execute @p[score_GAME_min:1], '~ ~ ~', 'scoreboard players reset * Score'
  execute @p[score_GAME_min:1], '~ ~ ~', 'scoreboard players set --RED-- Score 0'
  execute @p[score_GAME_min:1], '~ ~ ~', 'scoreboard players set --BLUE-- Score 0'
  execute @p[score_GAME_min:1], '~ ~ ~', 'scoreboard players reset @a ReturningFlag'
  execute @p[score_GAME_min:1], '~ ~ ~', 'scoreboard players reset @a ReturningOwnFlag'
  effect @a[score_GAME_min:1], 'minecraft:saturation', 1, 99
  effect @a[score_GAME_min:1], 'minecraft:instant_health', 1, 99
  spawnpoint @a[score_GAME_min:1, team:'Red'], 0, 34, 12
  spawnpoint @a[score_GAME_min:1, team:'Blue'], 50, 34, 12
  scoreboard :players, :reset, @a, 'GAME'
end

# pick up enemy flag
repeat 10, 6, -6, 24, 8, -6 do
  execute @a[team:'Red'], '~ ~ ~', :detect, '~ ~ ~', 'minecraft:standing_banner', 4, 'scoreboard players set @p CapturingFlag 1'
  execute @a[team:'Blue'], '~ ~ ~', :detect, '~ ~ ~', 'minecraft:standing_banner', 12, 'scoreboard players set @p CapturingFlag 1'
  execute @p[team:'Red', score_CapturingFlag_min:1], '~ ~ ~', :tellraw, @a, JSON.dump([
    {selector: "@p"},
    {text: " got the ", color: "reset"},
    {text: "Blue Flag", color: "blue"}
  ])
  replaceitem :entity, @p[team:'Red', score_CapturingFlag_min:1], 'slot.armor.head', 'minecraft:banner', 1, 4
  execute @p[team:'Blue', score_CapturingFlag_min:1], '~ ~ ~', :tellraw, @a, JSON.dump([
    {selector: "@p"},
    {text: " got the ", color: "reset"},
    {text: "Red Flag", color: "red"}
  ])
  replaceitem :entity, @p[team:'Blue', score_CapturingFlag_min:1], 'slot.armor.head', 'minecraft:banner', 1, 1
  execute @a[score_CapturingFlag_min:1], '~ ~ ~', 'setblock ~ ~ ~ minecraft:air'
  execute @a[score_CapturingFlag_min:1], '~ ~ ~', 'scoreboard players set @p HasFlag 1'
  execute @a[score_CapturingFlag_min:1], '~ ~ ~', 'scoreboard players reset @p CapturingFlag'
end

# capture enemy flag
repeat -8, 6, -4, 8, 8, -4 do
  execute @p[team:'Red', score_HasFlag_min:1, x: 0, y: 34, z: 12, r: 1], '~ ~ ~', :detect, '~ ~ ~', 'minecraft:standing_banner', 12, 'scoreboard players set @p ReturningFlag 1'
  execute @p[team:'Blue', score_HasFlag_min:1, x: 50, y: 34, z: 12, r: 1], '~ ~ ~', :detect, '~ ~ ~', 'minecraft:standing_banner', 4, 'scoreboard players set @p ReturningFlag 1'
  execute @p[team:'Red', score_ReturningFlag_min:1], '~ ~ ~', 'title @a title', JSON.dump([
    {text: "Score", color: "red"}
  ])
  execute @p[team:'Red', score_ReturningFlag_min:1], '~ ~ ~', 'title @a subtitle', JSON.dump([
    {selector: "@p"},
    {text: " captured the flag", color: "reset"}
  ])
  execute @p[team:'Blue', score_ReturningFlag_min:1], '~ ~ ~', 'title @a title', JSON.dump([
    {text: "Score", color: "blue"}
  ])
  execute @p[team:'Blue', score_ReturningFlag_min:1], '~ ~ ~', 'title @a subtitle', JSON.dump([
    {selector: "@p"},
    {text: " captured the flag", color: "reset"}
  ])

  # reset the flag
  execute @p[team:'Red', score_ReturningFlag_min:1], '~ ~ ~', 'setblock 50 34 12 minecraft:standing_banner 4'
  execute @p[team:'Red', score_ReturningFlag_min:1], '~ ~ ~', 'blockdata 50 34 12 {Base:4}'
  execute @p[team:'Blue', score_ReturningFlag_min:1], '~ ~ ~', 'setblock 0 34 12 minecraft:standing_banner 12'
  execute @p[team:'Blue', score_ReturningFlag_min:1], '~ ~ ~', 'blockdata 0 34 12 {Base:1}'
  replaceitem :entity, @a[score_ReturningFlag_min:1], 'slot.armor.head', 'minecraft:air'

  # scores
  execute @p[team:'Red', score_ReturningFlag_min:1], '~ ~ ~', 'scoreboard players add --RED-- Score 1'
  execute @p[team:'Blue', score_ReturningFlag_min:1], '~ ~ ~', 'scoreboard players add --BLUE-- Score 1'
  scoreboard :players, :add, @p[score_ReturningFlag_min:1], 'Score', 1
  execute @a[score_ReturningFlag_min:1], '~ ~ ~', 'scoreboard players reset @p HasFlag'
  execute @a[score_ReturningFlag_min:1], '~ ~ ~', 'scoreboard players reset @p ReturningFlag'
end

# drop flag on death
repeat 10, 6, -4, 24, 8, -4 do
  # only @a includes dead players
  execute @a[score_IsDead_min:1, score_HasFlag_min:1, team: 'Red'], '~ ~ ~', :tellraw, @a, JSON.dump([
    {selector: @a[score_IsDead_min:1, score_HasFlag_min:1, team: 'Red']},
    {text: " dropped the ", color: "reset"},
    {text: "Blue Flag", color: "blue"}
  ])
  execute @a[score_IsDead_min:1, score_HasFlag_min:1, team: 'Blue'], '~ ~ ~', :tellraw, @a, JSON.dump([
    {selector: @a[score_IsDead_min:1, score_HasFlag_min:1, team: 'Blue']},
    {text: " dropped the ", color: "reset"},
    {text: "Red Flag", color: "red"}
  ])
  execute @a[score_IsDead_min:1, score_HasFlag_min:1, team: 'Red'], '~ ~ ~', :setblock, '~ ~ ~', 'minecraft:standing_banner', 4
  execute @a[score_IsDead_min:1, score_HasFlag_min:1, team: 'Red'], '~ ~ ~', :blockdata, '~ ~ ~', to_nbt({'Base'=>4})
  execute @a[score_IsDead_min:1, score_HasFlag_min:1, team: 'Blue'], '~ ~ ~', :setblock, '~ ~ ~', 'minecraft:standing_banner', 12
  execute @a[score_IsDead_min:1, score_HasFlag_min:1, team: 'Blue'], '~ ~ ~', :blockdata, '~ ~ ~', to_nbt({'Base'=>1})

  scoreboard :players, :reset, @a[score_IsDead_min:1], 'HasFlag'
  scoreboard :players, :reset, @a[score_IsDead_min:1], 'HasOwnFlag'
  scoreboard :players, :reset, @a[score_IsDead_min:1], 'IsDead'
end

# pick up own flag
repeat -8, 6, -2, 8, 8, -2 do
  execute @a[team:'Blue'], '~ ~ ~', :detect, '~ ~ ~', 'minecraft:standing_banner', 4, 'scoreboard players set @p CapturingOwnFlag 1'
  execute @a[team:'Red'], '~ ~ ~', :detect, '~ ~ ~', 'minecraft:standing_banner', 12, 'scoreboard players set @p CapturingOwnFlag 1'
  execute @a[score_CapturingOwnFlag_min:1], '~ ~ ~', :detect, '~ ~-1 ~', 'minecraft:gold_block', 0, 'scoreboard players reset @p CapturingOwnFlag'
  execute @p[team:'Blue', score_CapturingOwnFlag_min:1], '~ ~ ~', :tellraw, @a, JSON.dump([
    {selector: "@p"},
    {text: " got the ", color: "reset"},
    {text: "Blue Flag", color: "blue"}
  ])
  replaceitem :entity, @p[team:'Blue', score_CapturingOwnFlag_min:1], 'slot.armor.head', 'minecraft:banner', 1, 4
  execute @p[team:'Red', score_CapturingOwnFlag_min:1], '~ ~ ~', :tellraw, @a, JSON.dump([
    {selector: "@p"},
    {text: " got the ", color: "reset"},
    {text: "Red Flag", color: "red"}
  ])
  replaceitem :entity, @p[team:'Red', score_CapturingOwnFlag_min:1], 'slot.armor.head', 'minecraft:banner', 1, 1
  execute @a[score_CapturingOwnFlag_min:1], '~ ~ ~', 'setblock ~ ~ ~ minecraft:air'
  execute @a[score_CapturingOwnFlag_min:1], '~ ~ ~', 'scoreboard players set @p HasOwnFlag 1'
  execute @a[score_CapturingOwnFlag_min:1], '~ ~ ~', 'scoreboard players reset @p CapturingOwnFlag'
end

# return own flag
repeat 10, 6, -2, 24, 8, -2 do
  execute @a[team:'Blue', x: 50, y: 34, z: 12, r: 1, score_HasOwnFlag_min: 1], '~ ~ ~', 'scoreboard players set @p ReturningOwnFlag 1'
  execute @a[team:'Red', x: 0, y: 34, z: 12, r: 1, score_HasOwnFlag_min: 1], '~ ~ ~', 'scoreboard players set @p ReturningOwnFlag 1'
  execute @a[team:'Blue',score_ReturningOwnFlag_min:1], '~ ~ ~', 'setblock 50 34 12 minecraft:standing_banner 4'
  execute @a[team:'Blue',score_ReturningOwnFlag_min:1], '~ ~ ~', 'blockdata 50 34 12', to_nbt({'Base'=>4})
  execute @a[team:'Blue',score_ReturningOwnFlag_min:1], '~ ~ ~', 'tellraw @a', JSON.dump([
    {selector: "@p"},
    {text: " returned the ", color: "reset"},
    {text: "Blue Flag", color: "blue"}
  ])
  execute @a[team:'Red',score_ReturningOwnFlag_min:1], '~ ~ ~', 'setblock 0 34 12 minecraft:standing_banner 12'
  execute @a[team:'Red',score_ReturningOwnFlag_min:1], '~ ~ ~', 'blockdata 0 34 12', to_nbt({'Base'=>1})
  execute @a[team:'Red',score_ReturningOwnFlag_min:1], '~ ~ ~', 'tellraw @a', JSON.dump([
    {selector: "@p"},
    {text: " returned the ", color: "reset"},
    {text: "Red Flag", color: "red"}
  ])
  replaceitem :entity, @a[score_ReturningOwnFlag_min:1], 'slot.armor.head', 'minecraft:air'
  scoreboard :players, :reset, @a[score_ReturningOwnFlag_min:1], 'HasOwnFlag'
  scoreboard :players, :reset, @a[score_ReturningOwnFlag_min:1], 'ReturningOwnFlag'
end
