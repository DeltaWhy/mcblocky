require 'json'

module McBlocky
  module DSL
    def helper(*command, &block)
      context.helpers << [command, block]
    end

    def initial(&block)
      Initial.new(self).instance_exec(&block)
    end

    module Commands
      COMMANDS = [:achievement, :ban, :ban_ip, :banlist, :blockdata, :clear, :clone, :debug, :defaultgamemode, :deop, :difficulty, :effect, :enchant, :entitydata, :execute, :fill, :gamemode, :gamerule, :give, :help, :kick, :kill, :list, :me, :op, :pardon, :pardon_ip, :particle, :playsound, :replaceitem, :save_all, :save_off, :save_on, :say, :scoreboard, :seed, :setblock, :setidletimeout, :setworldspawn, :spawnpoint, :spreadplayers, :stats, :stop, :summon, :tell, :tellraw, :testfor, :testforblock, :testforblocks, :time, :title, :toggledownfall, :tp, :trigger, :weather, :whitelist, :worldborder, :xp]

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

    class Initial
      def initialize(context)
        @context = context
        @a = Selector.new '@a'
        @p = Selector.new '@p'
        @r = Selector.new '@r'
        @e = Selector.new '@e'
      end

      def command(*args)
        @context.initial_commands << args.map(&:to_s).join(' ')
      end

      include Commands
    end

    class Selector
      def initialize(name)
        @name = name
      end

      def [](**args)
        pairs = args.map{|k,v| "#{k}=#{v}"}
        "#{@name}[#{pairs.join(',')}]"
      end

      def to_s
        @name
      end
    end
  end
end
