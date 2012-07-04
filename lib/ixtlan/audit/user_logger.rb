require 'slf4r/logger'

module Ixtlan
  module Audit
    class UserLogger

      include ::Slf4r::Logger
      
      def initialize(audit_manager)
        @manager = audit_manager
      end

      private
      
      def login_from(controller)
        user = controller.respond_to?(:current_user) ? controller.send(:current_user) : nil
        user.nil? ? nil: user.send(@manager.username_method)
      end
      
      public
      
      def log(controller, message = nil, &block)
        log_user(login_from(controller), message, &block)
      end
      
      def log_action(controller, message = nil)
        log_user(login_from(controller)) do
          as_xml = controller.response.content_type == 'application/xml' ? " - xml" : ""
          if controller.params[:controller]
            clname = controller.params[:controller]
            cname = clname.sub(/^.*\//, '')
            audits = controller.instance_variable_get("@#{cname}")
            if(audits)
              "#{clname}##{controller.params[:action]} #{cname.classify}[#{audits.size}]#{as_xml}#{message}"
            else
              audit = controller.instance_variable_get("@#{cname.singularize}")
              if(audit)
                errors = if(audit.respond_to?(:errors) && !audit.errors.empty?)
                           " - errors: " + audit.errors.full_messages.join(", ")
                         end
                audit_log = if audit.respond_to?(:to_log)
                              audit.to_log
                            elsif audit.is_a? String
                              audit
                            else
                              "#{audit.class.name}(#{audit.id})"
                            end
                "#{clname}##{controller.params[:action]} #{audit_log}#{as_xml}#{message}#{errors}"
              else
                "#{clname}##{controller.params[:action]}#{as_xml}#{message}"
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
        @manager.push( msg, user)
        logger.debug {"[#{user}] #{msg}" }
      end
    end
  end
end
