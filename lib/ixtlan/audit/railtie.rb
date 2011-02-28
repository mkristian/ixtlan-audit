require 'ixtlan/audit/manager'
require 'ixtlan/audit/audit_rack'
require 'ixtlan/audit/user_logger'


module Ixtlan
  module Audit
    class Railtie < ::Rails::Railtie

      config.before_configuration do |app|
        app.config.class.class_eval do
          attr_accessor :audit_manager
        end
        app.config.audit_manager = Manager.new
        ::ActionController::Base.append_after_filter(Ixtlan::Audit::AuditFilter)
        ::ActionController::Base.append_before_filter(Ixtlan::Audit::AuditCleanupFilter)
        app.config.middleware.use Ixtlan::Audit::AuditRack
      end
    end

    class AuditFilter

      def self.logger
        @logger ||= UserLogger.new(Rails.application.config.audit_manager)
      end

      def self.filter(controller)
        logger.log_action(controller)
      end
    end

    
    class AuditCleanupFilter

      def self.filter(controller)
        Rails.application.config.audit_manager.daily_cleanup
      end
    end
  end
end
