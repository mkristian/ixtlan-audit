require 'ixtlan/babel/serializer'
module Ixtlan
  module Audit
    class AuditSerializer < Ixtlan::Babel::Serializer

      root 'audit'
      
      add_context( :single )
      
      add_context( :collection, :except => [:created_at] )
    end
  end
end

