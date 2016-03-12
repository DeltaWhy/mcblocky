module McBlocky
  module Logging
    RESET   = "\e[0m"
    BOLD    = "\e[1m"
    RED     = "\e[31m"
    GREEN   = "\e[32m"
    YELLOW  = "\e[33m"
    BLUE    = "\e[34m"
    MAGENTA = "\e[35m"
    CYAN    = "\e[36m"
    WHITE   = "\e[37m"

    @@mutex = Mutex.new

    def log_server(message)
      @@mutex.synchronize do
        puts "#{YELLOW}#{message.chomp}#{RESET}"
      end
    end

    def log_command(message)
      @@mutex.synchronize do
        puts "#{CYAN}#{BOLD}/#{message.chomp}#{RESET}"
      end
    end

    def log_status(message)
      @@mutex.synchronize do
        puts "#{GREEN}#{BOLD}---> #{message.chomp}#{RESET}"
      end
    end

    def log_error(message)
      @@mutex.synchronize do
        puts "#{RED}#{BOLD}---> #{message.chomp}#{RESET}"
      end
    end
  end
end
