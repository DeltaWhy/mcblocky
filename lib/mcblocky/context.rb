require 'mcblocky/dsl'

module McBlocky
  class Context
    attr_accessor :server

    def self.run_file(file, dir=nil)
      dir = File.dirname(file) unless dir
      Dir.chdir dir do
        begin
          ctx = Context.new
          f = open(file)
          ctx.instance_eval(f.read, file)
          return ctx
        ensure
          f.close if f
        end
      end
    end

    def helpers
      @helpers ||= []
    end

    def required_files
      @required_files ||= Set.new
    end

    def chains
      @chains ||= []
    end

    def blocks
      @blocks ||= {}
    end

    def rects
      @rects ||= {}
    end

    def areas
      @areas ||= []
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
