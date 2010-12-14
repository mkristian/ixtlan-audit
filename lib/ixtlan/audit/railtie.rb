require 'rails'

module Ixtlan
  module Audit
    class Railtie < Rails::Railtie

      config.before_configuration do |app|
        app.config.class.class_eval do
          attr_accessor :audit
        end
        app.config.audit = Ixtlan::Audit::Manager.new
      end
      
      config.after_initialization do |app|
        ::ActionController::Base.send(:include, Ixtlan::Audit::Base)
      end
    end

    module Base
      def self.included(base)
        base.append_after_filter(AuditFilter)
        base.append_before_filter(AuditCleanupFilter)
      end
    end

    class AuditFilter

      def self.logger
        @logger ||= UserLogger.new(Rails.application.config.audit, Ixtlan::Audit)
      end

      def self.filter(controller)
        logger.log_action(controller)
      end
    end

    
    class AuditCleanupFilter

      def self.filter(controller)
        Rails.application.config.audit.daily_cleanup
      end
    end
  end
end
