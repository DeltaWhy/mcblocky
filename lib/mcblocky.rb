module McBlocky
  def self.reload!
    McBlocky.send(:remove_const, :DSL) if defined? McBlocky::DSL
    McBlocky.send(:remove_const, :Context) if defined? McBlocky::Context
    McBlocky.send(:remove_const, :Executor) if defined? McBlocky::Executor
    load File.expand_path('mcblocky/dsl.rb', File.dirname(__FILE__))
    load File.expand_path('mcblocky/context.rb', File.dirname(__FILE__))
    load File.expand_path('mcblocky/executor.rb', File.dirname(__FILE__))
  end
end

# non-reloadable
require "mcblocky/config"
require "mcblocky/listener"
require "mcblocky/server"
require "mcblocky/version"
require "mcblocky/cli"

# reloadable
require "mcblocky/context"
require "mcblocky/dsl"
require "mcblocky/executor"
