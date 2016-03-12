require_relative 'helpers/foo'

helper 'hello' do |user|
  server.say "Hello, #{user}!"
end

