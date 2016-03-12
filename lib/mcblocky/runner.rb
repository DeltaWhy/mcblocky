module McBlocky
  class Runner
    def initialize(dir, main)
      @dir = dir
      @main = main
    end

    def run
      Dir.chdir @dir do
        begin
          McBlocky.send(:remove_const, :DSL) if defined? McBlocky::DSL
          McBlocky.send(:remove_const, :Context) if defined? McBlocky::Context
          load File.expand_path('dsl.rb', File.dirname(__FILE__))
          load File.expand_path('context.rb', File.dirname(__FILE__))
          ctx = Context.new
          f = open(@main)
          ctx.instance_eval(f.read, @main)
          return ctx
        ensure
          f.close if f
        end
      end
    end
  end
end
