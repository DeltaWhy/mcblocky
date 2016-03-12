helper 'foo', 'bar' do |args, user, command|
  server.say "#{command}, #{user}, #{args}"
end
