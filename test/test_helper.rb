$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'mcblocky'

require 'minitest/autorun'

Facing = McBlocky::DSL::Facing
Color = McBlocky::DSL::Color

def assert_valid &block
  ctx = McBlocky::Context.run_block &block
  McBlocky::Executor.to_commands ctx
end

def assert_invalid &block
  assert_raises(ArgumentError) {
    ctx = McBlocky::Context.run_block &block
    McBlocky::Executor.to_commands ctx
  }
end
