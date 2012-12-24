require 'cuba_api'
require 'ixtlan/audit/resource'
require 'ixtlan/audit/serializer'
module Ixtlan
  module Audit
    class Cuba < ::CubaAPI
      define do
        on get, :numder do |number|
          write Ixtlan::Audit::Audit.get!( number.to_i )
        end
        on get do
          write Ixtlan::Audit::Audit.all.reverse
        end
      end
    end
  end
end
