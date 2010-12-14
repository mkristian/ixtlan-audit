module Ixtlan
  class AuditRack
    def initialize(app)
      @app = app
    end

    def call(env)
      result = @app.call(env)
      Rails.application.config.audit.save_all
      result
    end

  end
end
