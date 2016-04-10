# Selectors
Many Minecraft commands accept an entity selector -- something like `@e[type=ArmorStand,x=1,y=2,z=3,r=1]`. McBlocky also understands selectors, which look slightly different in Ruby:
```ruby
@e[type: 'ArmorStand', x: 1, y: 2, z: 3, r: 1]
```

You can also save a partial selector to a variable and add more arguments to it later:
```ruby
foo = @a[x: 1, y: 2, z: 3, r: 1]
foo[team: 'Red'] # "@a[x=1,y=2,z=3,r=1,team=Red]"
foo[team: 'Blue'] # "@a[x=1,y=2,z=3,r=1,team=Blue]"
foo # "@a[x=1,y=2,z=3,r=1]"
```

As a shorthand, you can pass a `Location` object instead of the x, y, and z arguments.
```ruby
l = Location.new(1, 2, 3)
@a[loc: l] # "@a[x=1,y=2,z=3]"
```
