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
        @keep_logs = 90
      end
      
      def username_method=(method)
        @username_method = method.to_sym if method
      end
      
      def model=(m)
        @model = m if m
      end

      def keep_logs=(days)
        old = @keep_logs
        @keep_logs = days.to_i
        daily_cleanup if old != @keep_logs
      end
      
      def push(message, username)
        list << model.new(:message => message, :login => username) if model
        list.last
      end

      def save_all
        daily_cleanup
        list.each do |audit|
          begin
            audit.save
          rescue => e
            warn "unexpected error - skip entry"
            warn e.message
            warn audit
          end
        end
        list.clear
      end

      def username_method
        @username_method
      end

      def daily_cleanup
        if model
          if(@last_cleanup.nil? || @last_cleanup < 1.days.ago)
            @last_cleanup = 0.days.ago # to have the right type
            begin
              delete_all
              logger.info("cleaned audit logs")
            rescue Exception => e
              logger.error("cleanup audit logs", e)
            end
          end
        end
      end

      private

      if defined? ::DataMapper
        def delete_all
          model.all(:created_at.lte => @keep_logs.days.ago).destroy!
        end
      else # ActiveRecord
        def delete_all
          model.all(:conditions => ["created_at <= ?", @keep_logs.days.ago]).each(&:delete)
        end
      end
    end
  end
end
