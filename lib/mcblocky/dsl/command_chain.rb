module McBlocky::DSL
  class CommandChain
    def initialize(kind)
      @kind = kind
      @a = Selector.new '@a'
      @p = Selector.new '@p'
      @r = Selector.new '@r'
      @e = Selector.new '@e'
    end

    def commands
      @commands ||= []
    end

    def command(*args)
      commands << args.map(&:to_s).join(' ')
    end

    def to_nbt(obj)
      McBlocky::DSL.to_nbt(obj)
    end

    include Commands
  end
end
