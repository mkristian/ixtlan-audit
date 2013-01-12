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
module Ixtlan
  module Audit
    class UserLogger

      if defined? ::Slf4r
        include ::Slf4r::Logger
      else
        require 'logger'
        def logger
          @logger ||= Logger.new( STDOUT )
        end
      end

      def initialize(audit_manager)
        @manager = audit_manager
      end

      private
      
      def login_from(controller)
        user = controller.respond_to?(:current_user) ? controller.send(:current_user) : nil
        user.nil? ? nil: (user.respond_to?(:login) ? user.login : user.username)
      end
      
      public
      
      def log(controller, message = nil, &block)
        log_user(login_from(controller), message, &block)
      end
      
      def log_action(controller, message = nil)
        log_user(login_from(controller)) do
          if controller.params[:controller]
            clname = controller.params[:controller]
            cname = clname.sub(/^.*\//, '')
            audits = controller.instance_variable_get("@#{cname}")
            if(audits && audits.respond_to?(:collect))
              "#{clname}##{controller.params[:action]} #{cname.classify}[#{audits.size}]#{message}"
            else
              audit = audits || controller.instance_variable_get("@#{cname.singularize}")
              if(audit)
                errors = if(audit.respond_to?(:errors) && !audit.errors.empty?)
                           " - errors: " + audit.errors.full_messages.join(", ")
                         end
                audit_log = if audit.respond_to?(:to_log)
                              audit.to_log
                            elsif audit.is_a? String
                              audit
                            elsif audit.respond_to?(:model)
                              "#{audit.model}(#{audit.id})"
                            else
                              "#{audit.class.name}(#{audit.id})"
                            end
                "#{clname}##{controller.params[:action]} #{audit_log}#{message}#{errors}"
              else
                "#{clname}##{controller.params[:action]}#{message}"
              end
            end
          else
            "params=#{controller.params.inspect}#{message}"
          end
        end
      end
        
      def log_user(user, message = nil, &block)
        user ||= "???"
        msg = "#{message}#{block.call if block}"
        @manager.push( user, msg.sub(/\ .*$/, ''), msg.sub(/^[^\ ]*\ /, '') )
        logger.debug {"[#{user}] #{msg}" }
      end
    end
  end
end
