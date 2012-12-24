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
require 'ixtlan/audit/user_logger'


module Ixtlan
  module Audit
    class Railtie < ::Rails::Railtie

      config.before_configuration do |app|
        app.config.audit_manager = Manager.new
        ::ActionController::Base.send(:include, Module)
        ::ActionController::Base.send(:after_filter, :audit)
        app.config.middleware.use(Rack, app.config.audit_manager)
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