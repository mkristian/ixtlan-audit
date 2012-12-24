require 'ixtlan/audit/manager'
require 'ixtlan/audit/rack'
module Ixtlan
  module Audit
    module CubaPlugin
      def audit( obj, args )
        if args[ :audit ] != false
          username = current_user_name if respond_to?( :current_user_name )
          audit_manager.push( username, env['SCRIPT_NAME'], obj )
        end
        obj
      end
      
      def audit_manager
        @audit_manager ||= self.class[ :audit_manager ] || Manager.new
      end
      
      def self.included( base )
        base.prepend_aspect :audit
        manager = Manager.new
        base[ :audit_manager ] = manager
        base.use( Rack, manager)
      end
    end
  end
end
