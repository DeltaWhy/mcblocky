require 'mcblocky/dsl'

module McBlocky
  class Context
    def server
      $server
    end

    def helpers
      @helpers ||= []
    end

    def required_files
      @required_files ||= Set.new
    end

    def initial_commands
      @initial_commands ||= []
    end

    def context
      self
    end

    def require(file)
      if file.start_with? './'
        file = "#{file.sub('./','')}.rb" unless file.end_with? '.rb'
        required_files << file
        begin
          f = open(file)
          instance_eval(f.read, file)
          true
        ensure
          f.close if f
        end
      else
        Kernel.require(file)
      end
    end

    def require_relative(file)
      path = File.dirname caller[0].split('.rb')[0]
      file = "#{file}.rb" unless file.end_with? '.rb'
      file = File.expand_path(file, path)
      required_files << file
      begin
        f = open(file)
        instance_eval(f.read, file)
        true
      ensure
        f.close if f
      end
    end

    include McBlocky::DSL
  end
end
