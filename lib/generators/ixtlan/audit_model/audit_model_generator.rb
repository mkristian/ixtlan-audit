require 'generators/ixtlan/audit_base'
module Ixtlan
  module Generators
    class AuditModelGenerator < AuditBase
      
      protected
      def generator_name
        "model"
      end
    end
  end
end
