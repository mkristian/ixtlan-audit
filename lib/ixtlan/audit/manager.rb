module Ixtlan
  module Audit
    class Manager

      private

      if defined? ::Slf4r
        include ::Slf4r::Logger
      else
        require 'logger'
        def logger
          @logger ||= Logger.new( STDOUT )
        end
      end

      def list
        Thread.current[:audit] ||= []
      end

      public

      attr_accessor :model, :block, :keep_logs

      def initialize( model = nil, &block )
        @model = model
        @keep_logs = 90
        block.call( self ) if block
        @block = block
      end

      def model
        @model ||= (Ixtlan::Audit::Audit rescue nil)
      end

      def keep_logs=( keep )
        old = @keep_logs
        @keep_logs = keep
        daily_cleanup if old != @keep_logs
      end

      def keep_logs
        if block
          keep_logs = block.call
        end
        @keep_logs
      end
      
      def push( username, path, obj )
        if model
          message = 
            if !obj.is_a?( String ) && obj.respond_to?( :collect )
              if o = obj.first
                "#{o.class}[ #{obj.size} ]"
              else
                "[ 0 ] - <EMPTY ARRAY>"
              end
            else
              obj.to_s
            end
          list << model.new( :path => path, 
                             :message => message, 
                             :login => username || '???' )
        end
        list.last
      end

      def save_all
        daily_cleanup
        list.each do |audit|
          begin
            audit.save
          rescue => e
            warn "unexpected error - skip entry"
            warn e.message
            warn audit
          end
        end
        list.clear
      end

      def daily_cleanup
        return unless model
        now = DateTime.now
        if(@last_cleanup.nil? || @last_cleanup < (now - 1))
          @last_cleanup = now
          begin
            delete_all( now - keep_logs )
            logger.info "cleaned audit logs"
          rescue Exception => e
            logger.warn "error cleaning up audit logs: #{e.message}" 
          end
        end
      end
  
      private

      if defined? ::DataMapper
        def delete_all( expired )
          model.all( :created_at.lte => expired ).destroy!
        end
      else # ActiveRecord
        def delete_all( expired )
          model.all( :conditions => ["created_at <= ?", expired] ).each(&:delete)
        end
      end
    end
  end
end
