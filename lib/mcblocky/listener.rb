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
      @handler = block
    end

    def start
      @listener.start
      begin
        log_status "Loading"
        result = Context.run_file(@main, @dir)
      rescue Exception
        log_error "Error in loaded file:"
        puts $!
        return
      end
      @handler.call(result)
      @files = [@main] + result.required_files.to_a if result.required_files
    end

    def handle(modified, added, removed)
      @files.each do |f|
        f = File.expand_path(f, @dir).gsub('\\','/')
        if modified.include? f or added.include? f or removed.include? f
          begin
            log_status "Reloading..."
            McBlocky.reload!
            result = Context.run_file(@main, @dir)
          rescue Exception => e
            log_error "Error in loaded file:"
            puts e.backtrace.join("\n\t")
              .sub("\n\t", ": #{e}#{e.class ? " (#{e.class})" : ""}\n\t")
            break
          end
          @handler.call(result)
          @files = [@main] + result.required_files.to_a if result.required_files
          log_status "Reloaded."
          break
        end
      end
    end
  end
end
