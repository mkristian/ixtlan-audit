module Ixtlan
  module Audit
    class AuditRack

      def initialize(app, audit_manager)
        @app = app
        @audit_manager = audit_manager
        self.class_eval do
          include Rails.application.routes.url_helpers
        end
      end
      
      def call(env)
        result = @app.call(env)
        @audit_manager.save_all
        result
      end
      
    end
  end
end
