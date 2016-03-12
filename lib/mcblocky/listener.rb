require 'listen'
require 'mcblocky/logging'

module McBlocky
  class Listener
    include Logging

    def self.from_config(&block)
      Config.validate
      return Listener.new(File.dirname(Config.config_path), Config.config['code']['main'], &block)
    end

    def initialize(dir, main, &block)
      @dir = dir
      @main = main
      @files = [main]
      @listener = Listen.to(dir, only: /\.rb$/, &method(:handle))
      @runner = Runner.new(dir, main)
      @handler = block
    end

    def start
      @listener.start
      begin
        result = @runner.run
      rescue Exception
        log_error "Error in loaded file:"
        puts $!
        return
      end
      p result
      @files = [@main] + result.required_files.to_a if result.required_files
    end

    def handle(modified, added, removed)
      @files.each do |f|
        f = File.expand_path(f, @dir).gsub('\\','/')
        if modified.include? f or added.include? f or removed.include? f
          @handler.call
          begin
            result = @runner.run
          rescue Exception
            log_error "Error in loaded file:"
            puts $!
            break
          end
          p result
          @files = [@main] + result.required_files.to_a if result.required_files
          break
        end
      end
    end
  end
end
