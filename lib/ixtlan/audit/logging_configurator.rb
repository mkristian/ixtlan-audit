module Ixtlan
  module Audit
    class LoggingConfigurator

      @logger = Logging::Logger[self]
    
      def initialize(filename, options = {}, categories = [])
        @categories = categories
        @options = options
        @options[:filename] = 
          if filename.is_a? File
            filename
          else
            File.join(Rails.root, "log", filename.to_s)
          end.expand_path
        @options[:age] = 'daily'
        @options[:layout] = Logging.layouts.pattern(:pattern => '%d %m\n') unless @options[:layout]
      end
        
      def call(manager)
        @options[:keep] = manager.keep_log
        appender = Logging.appenders.rolling_file("audit", @options)
        @categories.each do |category|
          logger = Logging::Logger[category]
          logger.remove_appenders('audit')
          logger.add_appenders(audit_appender)
          @logger.debug("setup logger for #{category}")
        end
        Dir["@options[:filename].*.log"][manager.keep_log, 100000].sort.each do |f|
          FileUtils.rm_f(f)
        end
        @logger.info("initialized audit log . . .")
      end
    end
  end
end
