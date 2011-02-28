require 'rails/generators/base'
module Ixtlan
  module Generators
    class AuditBase < Rails::Generators::Base

      argument :name, :type => :string, :required => false
      
      protected
      def generator_name
        raise "please overwrite generator_name"
      end
      
      public
      def create
        args = []
        if name
          args << ARGV.shift
        else
          args << "audit"
        end
        
        args << "created_at:datetime"
        args << "login:string"
        args << "message:string"
        args += ARGV[0, 10000] || []
        
        generate generator_name, *args
      end
    end
  end
end
