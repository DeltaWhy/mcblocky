# McBlocky
McBlocky is a Ruby DSL for creating Minecraft command block contraptions and maps. It allows you to write Ruby code that gets translated into commands and command blocks in the Minecraft world. Because it does everything by executing commands in the server console, you can see the results of your changes in-game almost immediately after you hit 'Save' in your editor -- no need to restart the server to run MCEdit.

## Getting Started
To start your project, you first need to create a `config.yml` that tells McBlocky how to run the server. See an example [here](../examples/ctf/config.example.yml). Next, create your main Ruby file. By default McBlocky will look for a `.rb` file with the same name as the folder containing your `config.yml`, but you can specify another name if you prefer.

Let's start with an empty file called `hello.rb`. Now, start the server:
```
mcblocky start path/to/config.yml
```
If you've gotten your configuration right, you should see this message:
```
---> Server is ready! Connect to 127.0.0.1:25565
```
Start up Minecraft and connect to the server so you can see your changes in real time. You can stop the server by pressing `CTRL-C` or running the `stop` command in the console (other server commands work too).

## Basic commands
Add this to `hello.rb`:
```ruby
initial do
  say 'Hello', @p
end
```
When you save the file, you should see `Reloading...` in the McBlocky console and a greeting in-game. This is not terribly exciting, so let's do some useful setup.
```ruby
initial do
  say 'Hello', @p
  time :set, :day
  gamerule :doDaylightCycle, false
end
```
You should notice that the server doesn't greet you again. McBlocky tries to avoid redoing work where possible, so it will skip the first command since it has already run. If you add more commands onto the end of the `initial` block, only the new commands get executed, but if you add them in the middle, it will execute everything after the first change since it can't tell which commands might depend on each other.

## Leveraging Ruby
Let's create some teams for a minigame.
```ruby
initial do
  scoreboard :teams, :add, 'Red'
  scoreboard :teams, :option, 'Red', :color, 'red'
  scoreboard :teams, :add, 'Blue'
  scoreboard :teams, :option, 'Blue', :color, 'blue'
  scoreboard :teams, :add, 'Yellow'
  scoreboard :teams, :option, 'Yellow', :color, 'yellow'
  scoreboard :teams, :add, 'Green'
  scoreboard :teams, :option, 'Green', :color, 'green'
end
```
Hmm, this is a bit repetitive isn't it? Fortunately there is a shorthand for `scoreboard`:
```ruby
initial do
  scoreboard :teams do
    add 'Red'
    option 'Red', :color, 'red'
    add 'Blue'
    option 'Blue', :color, 'blue'
    add 'Yellow'
    option 'Yellow', :color, 'yellow'
    add 'Green'
    option 'Green', :color, 'green'
  end
end
```
This is a more readable but if we wanted more than four teams it would still be a bit unwieldy. But since this is just Ruby code, we can use an `each` loop instead of repeating ourselves.
```ruby
initial do
  ['red', 'blue', 'yellow', 'green'].each do |color|
    scoreboard :teams do
      add color.capitalize
      option color.capitalize, :color, color
    end
  end
end
```
All three snippets are equivalent, so you can use whichever form you prefer.

## Placing blocks
Initial commands are useful for setting up the scoreboard and gamerules, but to do anything interesting we'll need some command blocks. You can use a `setblock` command (outside of the `initial` block) to place one. Let's give it a button too. (Change the coordinates to somewhere above ground and close to your player).
```ruby
setblock -89, 34, -95, 'minecraft:command_block', 0, :replace, {Command: 'say Hello @p'}
setblock -90, 34, -95, 'minecraft:stone_button', 2
```
Try commenting out one of these lines -- you'll notice McBlocky tries to clean up after itself by setting the block back to air. You can set any block this way, but there is a shorthand for command blocks:
```ruby
at -89, 34, -95 do
  say 'Hello', @p
end
```
You can also set the direction, type, and NBT tags of the command block:
```ruby
at -89, 34, -95, Facing::EAST, :repeating, {auto: 1} do
  say 'Hello', @p
end
```
Try out the `fill` command (outside of the `initial` block) too.

## Command chains
Of course, we don't really want to specify the position and data tags of every command block individually, we just want to write code and have it do cool stuff! For the common pattern of an always-on repeating command block followed by always-on chain command blocks, we can just specify a bounding box and let McBlocky handle the rest.

Let's create some pads that players can step on to join a team.
```ruby
# ...scoreboard setup omitted

setblock -5, 34, 0, 'minecraft:wool', Color::RED
setblock 5, 34, 0, 'minecraft:wool', Color::BLUE

# use an underground area that's much bigger than we really need
repeat -5, 5, -5, 5, 10, 5 do
  scoreboard :players, :set, @a[x: -5, y: 35, z: 0, r: 1, team: '!Red'], 'SwitchingTeam', 1
  scoreboard :players, :set, @a[x: 5, y: 35, z: 0, r: 1, team: '!Blue'], 'SwitchingTeam', 1
  
  execute @a[x: -5, y: 35, z: 0, r: 1, score_SwitchingTeam_min: 1] do
    scoreboard :teams, :join, 'Red', @p
    tellraw @a, {selector: @p}, {text: ' joined the ', color: 'reset'}, {text: 'Red team', color: 'red'}
  end

  execute @a[x: 5, y: 35, z: 0, r: 1, score_SwitchingTeam_min: 1] do
    scoreboard :teams, :join, 'Blue', @p
    tellraw @a, {selector: @p}, {text: ' joined the ', color: 'reset'}, {text: 'Blue team', color: 'blue'}
  end
  
  scoreboard :players, :reset, @a, 'SwitchingTeam'
end
```

## Next steps
Check out the [examples folder](../examples) for some longer examples. Then try making one of your own! Also have a look at the rest of the [documentation](../doc) *(coming soon)*.

Please report bugs and feature requests on the [issue tracker](https://github.com/DeltaWhy/mcblocky/issues). I will also accept pull requests for the code, documentation, and examples.

If you build a map with this, I'd love to hear about it! Drop me a line on Twitter [@michaellimiero](https://twitter.com/michaellimiero) and I'll add a link to your project in the README.
