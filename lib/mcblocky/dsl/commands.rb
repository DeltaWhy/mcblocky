module McBlocky::DSL
  class Commands
    attr_reader :kind

    def initialize(kind, *args)
      @kind = kind
      @args = args
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

    COMMANDS = [:achievement, :ban, :ban_ip, :banlist, :blockdata, :clear, :clone, :debug, :defaultgamemode, :deop, :difficulty, :effect, :enchant, :entitydata, :execute, :fill, :gamemode, :gamerule, :give, :help, :kick, :kill, :list, :me, :op, :pardon, :pardon_ip, :particle, :playsound, :replaceitem, :save_all, :save_off, :save_on, :say, :scoreboard, :seed, :setblock, :setidletimeout, :setworldspawn, :spawnpoint, :spreadplayers, :stats, :stop, :summon, :tell, :tellraw, :testfor, :testforblock, :testforblocks, :time, :title, :toggledownfall, :tp, :trigger, :weather, :whitelist, :worldborder, :xp]

    def blockdata(x, y, z, dataTag)
      command :blockdata, x, y, z, to_nbt(dataTag)
    end

    def clear(player, item, data, maxCount, dataTag)

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

    def setblock(x, y, z, block, dataValue=nil, replaceMode=nil, dataTag=nil)
      dataTag = to_nbt(dataTag) if dataTag
      args = [x, y, z, block, dataValue, replaceMode, dataTag].compact
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

    COMMANDS.each do |c|
      unless method_defined? c
        define_method c do |*args|
          command c.to_s.gsub('_', '-'), *args
        end
      end
    end
  end
end
