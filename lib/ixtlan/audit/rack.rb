module Ixtlan
  module Audit
    class Rack

      def initialize(app, audit_manager)
        @app = app
        @audit_manager = audit_manager
      end
      
      def call(env)
        result = @app.call(env)
        @audit_manager.save_all
        result
      end
      
    end
  end
end
