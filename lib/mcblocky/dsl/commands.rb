module McBlocky::DSL
  class Commands
    attr_reader :kind
    attr_accessor :commands

    def initialize(kind, *args)
      @kind = kind
      @args = args
      @commands = []
      @a = Selector.new '@a'
      @p = Selector.new '@p'
      @r = Selector.new '@r'
      @e = Selector.new '@e'
    end

    def command(*args)
      commands << args.map(&:to_s).join(' ')
    end

    def to_nbt(obj)
      McBlocky::DSL.to_nbt(obj)
    end

    COMMANDS = [:achievement, :ban, :ban_ip, :banlist, :blockdata, :clear, :clone, :debug, :defaultgamemode, :deop, :difficulty, :effect, :enchant, :entitydata, :execute, :fill, :gamemode, :gamerule, :give, :help, :kick, :kill, :list, :me, :op, :pardon, :pardon_ip, :particle, :playsound, :replaceitem, :save_all, :save_off, :save_on, :say, :scoreboard, :seed, :setblock, :setidletimeout, :setworldspawn, :spawnpoint, :spreadplayers, :stats, :stop, :summon, :tell, :tellraw, :testfor, :testforblock, :testforblocks, :time, :title, :toggledownfall, :tp, :trigger, :weather, :whitelist, :worldborder, :xp]

    def blockdata(*args)
      args[-1] = to_nbt(args[-1]) if Hash === args[-1]
      command :blockdata, *args
    end

    def execute(selector, *args, &block)
      if args.empty?
        args = ['~ ~ ~']
      end
      if block
        chain = Commands.new(:execute)
        chain.instance_exec &block
        chain.commands.each do |c|
          command :execute, selector, *args, c
        end
      else
        command :execute, selector, *args
      end
    end

    def gamerule(rule=nil, value=nil, &block)
      if (rule and block) or (rule and value.nil?)
        raise ArgumentError
      end
      unless block
        command :gamerule, rule, value
      else
        o = PartialCommand.new(self, :gamerule)
        o.instance_exec &block
      end
    end

    def replaceitem(*args)
      args[-1] = to_nbt(args[-1]) if Hash === args[-1]
      command :replaceitem, *args
    end

    def scoreboard(*args, &block)
      if block
        d = SimpleDelegator.new(self)
        d.instance_variable_set :@a, @a
        d.instance_variable_set :@p, @p
        d.instance_variable_set :@r, @r
        d.instance_variable_set :@e, @e
        d.instance_variable_set :@args, args
        def d.method_missing(m, *a)
          super
        rescue NoMethodError
          command :scoreboard, *@args, m, *a
        end
        d.instance_exec(&block)
      else
        command :scoreboard, *args
      end
    end

    def setblock(*args)
      args[-1] = to_nbt(args[-1]) if Hash === args[-1]
      command :setblock, *args
    end

    def tellraw(player, *args)
      if args.length < 1
        raise ArgumentError, "No message given in tellraw"
      end
      obj = []
      args.each do |arg|
        if Array === arg
          obj += arg
        else
          obj << arg
        end
      end
      command :tellraw, player, JSON.dump(obj)
    end

    def title(selector, subcommand, *args)
      if args.length < 1
        raise ArgumentError, "No message given in title"
      end
      obj = []
      args.each do |arg|
        if Array === arg
          obj += arg
        else
          obj << arg
        end
      end
      command :title, selector, subcommand, JSON.dump(obj)
    end

    COMMANDS.each do |c|
      unless method_defined? c
        define_method c do |*args|
          command c.to_s.gsub('_', '-'), *args
        end
      end
    end
  end

  class PartialCommand
    def initialize(context, *args)
      @context = context
      @args = args
      @a = Selector.new '@a'
      @p = Selector.new '@p'
      @r = Selector.new '@r'
      @e = Selector.new '@e'
    end

    def method_missing(m, *args)
      @context.command *(@args + [m] + args)
    end
  end
end
