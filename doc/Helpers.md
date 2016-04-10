# Helpers
You can define helpers for frequently used commands to make them easier to run. Helpers are triggered by sending `!name` in the chat, and are executed in the server console.

Currently the DSL commands are not available inside a helper block -- instead use `server.command` to send the command as a string, or `server.say` to send a console message.

A helper block receives two arguments: the first is an array of words that were given after the helper name, the second is the username of the player who triggered the helper.

## Examples
```ruby
helper 'blue' do |args, user|
  # filter out any color codes from the username
  user = user.gsub(/[^A-Za-z0-9_]./, '')
  server.command "scoreboard teams join Blue #{user}"
end
```
