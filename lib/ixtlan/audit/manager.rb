require 'slf4r/logger'

module Ixtlan
  module Audit
    class Manager

      private

      include ::Slf4r::Logger

      def list
        Thread.current[:audit] ||= []
      end

      public

      def initialize
        @model = AuditModel
        @username_method = :login
        @skip_logsystem = true
        @keep_log = 90
      end

      def username_method=(method)
        @username_method = method.to_sym if method
      end
      
      def model=(model)
        @model = model if model
      end

      def keep_log=(days)
        @keep_log = days.to_i
        if @observer
          @observer.call(@keep_log)
        end
      end
      
      def observer=(observer)
        @observer = observer
        if observer || @keep_log
          observer.call(@keep_log)
        end
      end
 
      def push(message, username)
        list << @model.new(:date => DateTime.now, :message => message, :login => username)
      end

      def save_all
        list.each do |audit|
          audit.save
        end
        Thread.current[:audit] = nil
      end

       def username_method
        @username_method
      end

      def daily_cleanup
        unless @model.is_a? AuditModel
          if(!@last_cleanup.nil? && @last_cleanup < 1.days.ago)
            @last_cleanup = Date.today
            begin
              #TODO switch between ActiveRecord && DataMapper
              @model.all(:date.lt => @keep_log.days.ago).destroy!
              @logger.info("cleaned audit logs")
            rescue Error
              # TODO log this !!
            end
          end
        end
      end
    end
  end
end
