fill -100, 32, -100, -90, 32, -90, 'minecraft:log'
fill -101, 33, -101, -89, 34, -101, 'minecraft:barrier'
fill -101, 33, -89, -89, 34, -89, 'minecraft:barrier'
fill -101, 33, -100, -101, 34, -90, 'minecraft:barrier'
fill -89, 33, -100, -89, 34, -90, 'minecraft:stained_hardened_clay', Color::LIGHT_BLUE

setblock -95, 32, -95, 'minecraft:glowstone'
setblock -89, 34, -95, 'minecraft:wool', Color::LIME
setblock -90, 34, -95, 'minecraft:stone_button', 2
setblock -90, 33, -95, 'minecraft:wall_sign', Facing::WEST, 'replace', {'Text2'=>'{"text":"Start Game"}'}
at -88, 34, -95 do
  scoreboard :players, :set, @a, 'GAME', 1
end

fill -100, 32, -92, -100, 32, -98, 'minecraft:wool', Color::WHITE
fill -99, 32, -93, -99, 32, -97, 'minecraft:wool', Color::WHITE
fill -92, 32, -100, -98, 32, -100, 'minecraft:wool', Color::RED
fill -93, 32, -99, -97, 32, -99, 'minecraft:wool', Color::RED
fill -92, 32, -90, -98, 32, -90, 'minecraft:wool', Color::BLUE
fill -93, 32, -91, -97, 32, -91, 'minecraft:wool', Color::BLUE
