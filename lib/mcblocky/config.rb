require 'yaml'

module McBlocky
  class Config
    class << self
      attr_reader :config
      attr_reader :config_path
      def load(filename)
        @valid = false
        filename = File.expand_path('config.yml', filename) if File.directory? filename
        @config_path = filename
        open(filename) do |f|
          @config = YAML.safe_load(f)
        end
        validate
      end

      def validate
        return if @valid
        raise ArgumentError, "No config loaded" unless config
        raise ArgumentError, "No server section" unless config['server']
        config['code'] ||= {}

        if config['server']['ops']
          raise ArgumentError, "server.ops must be an array" unless Array === config['server']['ops']
        end

        config['server']['properties'] = {'enable-command-block' => 'true'}.merge(config['server']['properties'] || {})

        Dir.chdir File.dirname(config_path) do
          unless which 'java'
            java = config['server']['java']
            raise ArgumentError, "Java not found. Specify the full path in server.java" if !java or java.empty?
            raise ArgumentError, "Java specified in server.java is not executable" unless File.executable? java
          end

          jar = config['server']['jar']
          raise ArgumentError, "No server.jar specified" if !jar or jar.empty?
          raise ArgumentError, "Jar specified in server.jar does not exist" unless File.exist? jar

          config['code']['main'] ||= "#{File.basename File.dirname(config_path)}.rb"
          main = config['code']['main']
          raise ArgumentError, "No code.main specified" if !main or main.empty?
          raise ArgumentError, "#{main} does not exist" unless File.exist? main or File.exist? "#{main}.rb"
        end

        @valid = true
      end

      protected
      def which(cmd)
        exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
        ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
          exts.each { |ext|
            exe = File.join(path, "#{cmd}#{ext}")
            return exe if File.executable?(exe) && !File.directory?(exe)
          }
        end
        return nil
      end
    end
  end
end
