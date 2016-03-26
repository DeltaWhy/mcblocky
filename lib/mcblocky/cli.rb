require "yaml"
require "thor"

module McBlocky
  class Cli < Thor
    include Logging

    class_option :config,
      desc: 'Path to config file',
      default: 'config.yml',
      type: :string,
      aliases: '-f'

    desc "list", "List commands that would be sent to the server"
    option :watch, aliases: '-w'
    def list
      begin
        Config.load(options[:config])
      rescue ArgumentError => e
        log_error "Error in #{File.basename Config.config_path}:"
        log_error e.message
        exit 1
      end
      if options[:watch]
        listener = Listener.from_config do |context|
          Executor.to_commands(context).each{|c| puts c}
        end
        listener.start
        while true; end
      else
        context = Context.run_file(Config.config['code']['main'], File.dirname(Config.config_path))
        Executor.to_commands(context).each{|c| puts c}
      end
    rescue Interrupt
    end

    desc "start", "Start the server"
    def start
      begin
        Config.load(options[:config])
      rescue ArgumentError => e
        log_error "Error in #{File.basename Config.config_path}:"
        log_error e.message
        exit 1
      end
      $server = Server.from_config
      log_status "Starting server..."
      $server.start
      log_status "Server is ready! Connect to 127.0.0.1:25565"
      reader = Thread.new do
        until $stdin.closed?
          line = $stdin.gets.chomp
          $server.command line unless line.empty?
        end
      end
      $server.say("McBlocky is ready")
      $server.on_message '!stop' do
        log_status "Stopping server..."
        $server.stop
      end
      $server.on_message /^!/ do |message, user|
        next unless $context
        command, _, args = message.partition(/\s+/)
        $context.helpers.each do |aliases, block|
          aliases = [aliases] if String === aliases
          aliases.each do |a|
            if command == "!#{a}"
              block.call(args, user, a)
              break
            end
          end
        end
      end
      listener = Listener.from_config do |context|
        old_context = $context
        $context = context
        $context.server = $server # needed by helpers
        Executor.to_commands(context, old_context).each{|c| $server.command c}
      end
      listener.start
      $server.loop!
    rescue SystemExit
      if $server
        log_status "Stopping server..."
        $server.stop
      end
      reader.kill if reader
    rescue Interrupt
      if $server
        log_status "Stopping server..."
        $server.stop
      end
      reader.kill if reader
    rescue Exception
      log_error "Caught error, stopping server..."
      begin
        $server.stop if $server
        reader.kill if reader
      rescue
      end
      log_error "Error trace:"
      raise
    end
  end
end
