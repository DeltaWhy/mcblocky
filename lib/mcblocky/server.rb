require "open3"
require "mcblocky/logging"

module McBlocky
  class ServerShutdown < StandardError; end
  class Server
    include Logging
    def initialize(jar, workdir)
      @jar = jar
      @workdir = workdir
      @queue = Queue.new
      @matchers = []
      @state = :not_started
    end

    def start
      Dir.chdir @workdir do
        @stdin, @stdout, @wait_thr = Open3.popen2e "java -jar #{@jar} nogui"
      end
      @reader = Thread.new(@stdout) do |stream|
        until stream.closed?
          begin
            line = stream.readline
            @queue << line
            log_server line
          rescue EOFError
            break
          end
        end
        Thread.main.raise ServerShutdown
      end
    end

    def command(cmd)
      log_command cmd
      @stdin.write("#{cmd}\r\n")
    end

    def wait_for_line(match)
      begin
        line = @queue.pop
        @matchers.each do |m, block|
          block.call(line) if m === line
        end
      end until match === line
      line
    end

    def on_line(match, &block)
      @matchers << [match, block]
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

    def loop
      while true
        line = @queue.pop
        @matchers.each do |m, block|
          block.call(line) if m === line
        end
      end
    rescue ServerShutdown
      log_status "Server stopped."
      join
    end

    def join
      @wait_thr.join
      @reader.join
    end
  end
end
