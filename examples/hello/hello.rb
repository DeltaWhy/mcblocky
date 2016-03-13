require_relative 'helpers/foo'

helper 'hello' do |user|
  server.say "Hello, #{user}!"
end

initial do
  gamerule 'doDaylightCycle', false
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

  tellraw @a[team: 'Red'], {text: "Hello", color: "red"}
end
