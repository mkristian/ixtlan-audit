#
# Copyright (C) 2012 Christian Meier
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
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