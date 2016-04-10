# Syntax
McBlocky syntax is, first and foremost, Ruby syntax. If you're not familiar with Ruby you should check out [Ruby in Twenty Minutes](https://www.ruby-lang.org/en/documentation/quickstart/) first, as it's a bit different from most other programming languages.

To do anything useful with McBlocky you'll need to call its functions. Several top-level functions are available, most of which take a Ruby block. More commands are available inside these blocks depending on what the function is.

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->


- [Top level functions](#top-level-functions)
  - [require and require_relative](#require-and-require_relative)
  - [helper](#helper)
  - [initial](#initial)
  - [cleanup](#cleanup)
  - [after](#after)
  - [setblock](#setblock)
  - [fill](#fill)
  - [at](#at)
  - [repeat](#repeat)
  - [chest](#chest)
  - [trapped_chest](#trapped_chest)
  - [dispenser](#dispenser)
  - [dropper](#dropper)
  - [furnace](#furnace)
- [Command context](#command-context)
  - [execute](#execute)
  - [detect](#detect)
  - [gamerule](#gamerule)
  - [scoreboard](#scoreboard)
- [Container context](#container-context)
  - [item](#item)
  - [item_in_slot](#item_in_slot)
- [NBT and JSON](#nbt-and-json)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

## Top level functions
### require and require_relative
These are actually Ruby functions, but it's worth mentioning that they work in McBlocky. `require` given a relative path will evaluate it relative to the root of your project (the location of your `config.yml`). `require_relative` evaluates relative to the *current file*.

### helper
```ruby
helper name do |args, user|
  # helper context
end
```
See [Helpers.md].

### initial
```ruby
initial do
  # command context
end
```
Commands to be executed before setting any blocks.

### cleanup
```ruby
cleanup do
  # command context
end
```
Commands to be executed before reloading the file.

### after
```ruby
after do
  # command context
end
```
Commands to be executed after setting all blocks.

### setblock
```ruby
setblock x, y, z, kind, data, replacemode, nbt
# does not take a block
```
Set a specific block in the world. The top level `setblock` is smart when reloading, so you should use it instead of `setblock` inside an `initial` context.

### fill
```ruby
fill x1, y1, z1, x2, y2, z2, kind, data
```
Fill an area in the world. Be careful with this one as a typo can be very destructive.

### at
```ruby
at x, y, z, data, kind, nbt do
  # command context
end
```
Place a command block with the command given. `kind` can be `:normal`, `:chain`, or `:repeating`. Note that you can only have one command inside the block.

### repeat
```ruby
repeat x1, y1, z1, x2, y2, z2 do
  # command context
end
```
Place a repeating command block chain within an area. Commands within this block will execute in order every tick. Ordering between different blocks depends on their world position.

### chest
```ruby
chest x, y, z, data do
  # container context
end
```
Place a chest in the world with the given contents.

### trapped_chest
```ruby
chest x, y, z, data do
  # container context
end
```
Place a trapped chest in the world with the given contents.

### dispenser
```ruby
chest x, y, z, data do
  # container context
end
```
Place a dispenser in the world with the given contents.

### dropper
```ruby
chest x, y, z, data do
  # container context
end
```
Place a dropper in the world with the given contents.

### furnace
```ruby
chest x, y, z, data do
  # container context
end
```
Place a furnace in the world with the given contents.


## Command context
All Minecraft commands are available within a command context. The following shorthands are also available:

### execute
```ruby
execute selector ... do
  # command context
end
```
Commands inside the block are prefixed by the given `execute` fragment. If you do not specify any arguments after the selector, it will add the `~ ~ ~` for you.

### detect
```ruby
detect selector ... do
  # command context
end
```
Shorthand for `execute selector, '~ ~ ~', :detect ...`. If you do not specify any arguments after the selector, it will add `~ ~ ~` for you.

### gamerule
```ruby
gamerule do
  rule value
  rule value
  ...
end
```
Commands inside the block are treated as names of gamerules to set.

### scoreboard
```ruby
scoreboard ... do
  ...
end
```
Commands inside the block are prefixed with the arguments given.

## Container context
### item
```ruby
item kind, count, damage, nbt
```
Add an item to the next available slot in this container.

### item_in_slot
```ruby
item_in_slot slot, kind, count, damage, nbt
```
Add an item to a specific slot in this container.

## NBT and JSON
Ruby hashes can usually be automatically converted to an NBT or JSON string (whichever is appropriate for a given command). If this conversion doesn't happen, you can use `to_nbt` or `to_json`, available in any context.
