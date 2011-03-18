module Ixtlan
  module Audit
    class AuditRack

      def initialize(app)
        @app = app
        self.class_eval do
          include Rails.application.routes.url_helpers
        end
      end
      
      def call(env)
        result = @app.call(env)
        ::Rails.application.config.audit_manager.save_all
        result
      end
      
    end
  end
end
