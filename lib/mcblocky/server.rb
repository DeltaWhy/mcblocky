require "open3"
require "mcblocky/logging"

module McBlocky
  class ServerShutdown < StandardError; end
  class Server
    include Logging
    def self.from_config
      Config.validate
      server = Config.config['server']
      workdir = File.expand_path(server['workdir'], File.dirname(Config.config_path))
      Dir.mkdir workdir unless Dir.exist? workdir
      Dir.chdir workdir do
        if server['eula']
          open('eula.txt', 'w') do |f|
            f.write("eula=true#{$/}")
          end
        end

        set_server_properties(server['properties'])
      end
      return Server.new(server['jar'], workdir, server['java'], server['ops'])
    end

    def self.set_server_properties(properties, filename='server.properties')
      lines = if File.exist? filename
                open(filename).readlines
              else
                []
              end
      properties.each do |k,v|
        if !lines.select{|l| l.start_with? "#{k}="}.empty?
          lines.map! do |l|
            if l.start_with? "#{k}="
              "#{k}=#{v}#{$/}"
            else
              l
            end
          end
        else
          lines << "#{k}=#{v}#{$/}"
        end
      end
      IO.write(filename, lines.join(''))
    end

    def initialize(jar, workdir, java=nil, ops=nil)
      @java = java || 'java'
      @jar = jar
      @workdir = workdir
      @queue = Queue.new
      @matchers = []
      @message_matchers = []
      @ops = ops
    end

    def start
      Dir.chdir @workdir do
        @stdin, @stdout, @wait_thr = Open3.popen2e "#{@java} -jar #{@jar} nogui"
      end
      @reader = Thread.new(@stdout) do |stream|
        until stream.closed?
          begin
            line = stream.readline
            @queue << line
            log_server line
            if line =~ /\<([^>]+)\> (.*)$/
              log_message "<#{$1}> #{$2}"
            end
          rescue EOFError
            break
          end
        end
        Thread.main.raise ServerShutdown
      end
      wait_for_line /Done \(.*?\)!/
      if @ops
        @ops.each {|op| command "op #{op}"}
      end
    end

    def command(cmd)
      log_command cmd
      @stdin.write("#{cmd}#{$/}")
    end

    def say(message)
      log_message "[Server] #{message}"
      @stdin.write("say #{message}#{$/}")
    end

    def on_line(match, &block)
      @matchers << [match, block]
    end

    def on_message(match, user=nil, &block)
      @message_matchers << [match, user, block]
    end

    def stop
      unless @stopping
        @matchers = []
        command "stop"
        @stdin.close
        @stopping = true
      end
      join
    end

    def loop!
      wait_for_line nil
    rescue ServerShutdown
      log_status "Server stopped."
      join
    end

    private
    def wait_for_line(match)
      begin
        line = @queue.pop
        @matchers.each do |m, block|
          block.call(line) if m === line
        end
        if line =~ /\<([^>]+)\> (.*)$/
          user, message = $1, $2
          @message_matchers.each do |m, u, block|
            if !u or u == user or u === user
              if m === message
                block.call(message, user)
              end
            end
          end
        end
      end until match and match === line
      line
    end

    def join
      @wait_thr.join
      @reader.join
    end
  end
end
