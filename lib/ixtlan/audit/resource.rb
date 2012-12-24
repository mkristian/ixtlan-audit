require 'dm-core'
module Ixtlan
  module Audit
    class Audit
      include DataMapper::Resource

      property :id, Serial
      
      property :login, String
      property :path, String
      property :message, String
      
      property :created_at, DateTime
      
      before :save do
        self.created_at = DateTime.now
      end
    end
  end
end
