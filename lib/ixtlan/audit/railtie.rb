require 'ixtlan/audit/manager'
require 'ixtlan/audit/audit_rack'
require 'ixtlan/audit/user_logger'


module Ixtlan
  module Audit
    class Railtie < ::Rails::Railtie

      config.before_configuration do |app|
        app.config.audit_manager = Manager.new
        ::ActionController::Base.send(:include, Module)
        ::ActionController::Base.send(:after_filter, :audit)
        app.config.middleware.use AuditRack, app.config.audit_manager
      end
    end
    
    module Module

      def audit
        @audit_logger ||= UserLogger.new(Rails.application.config.audit_manager)
        @audit_logger.log_action(self)
      end
    end
  end
end
