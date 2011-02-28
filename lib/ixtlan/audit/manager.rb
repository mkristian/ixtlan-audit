require 'slf4r/logger'

module Ixtlan
  module Audit
    class Manager

      private

      include ::Slf4r::Logger

      def list
        Thread.current[:audit] ||= []
      end

      def model
        @model ||= (::Audit rescue nil)
      end

      public

      def initialize
        @username_method = :login
        @keep_log = 90
      end

      def username_method=(method)
        @username_method = method.to_sym if method
      end
      
      def model=(m)
        @model = m if m
      end

      def keep_log=(days)
        @keep_log = days.to_i
      end
      
      def push(message, username)
        list << model.new(:message => message, :login => username) if model
        list.last
      end

      def save_all
        list.each do |audit|
          audit.save
        end
        list.clear
      end

      def username_method
        @username_method
      end

      def daily_cleanup
        if @model
          if(!@last_cleanup.nil? && @last_cleanup < 1.days.ago)
            @last_cleanup = Date.today
            begin
              if defined? ::DataMapper
                @model.all(:date.lt => @keep_log.days.ago).destroy!
              else # ActiveRecord
                @model.all(:conditions => ["date < ?", @keep_log.days.ago]).each(&:delete)
              end
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
