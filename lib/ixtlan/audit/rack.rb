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
    class Rack

      def self.runner( manager )
        @runner ||= Thread.new do
          while true do
            sleep 1
            while not queue.empty?
              list = queue.pop
              manager.save_all( list )
            end
          end
        end
      end

      def self.queue
        @queue ||= Queue.new
      end

      def initialize(app, audit_manager)
        @app = app
        @audit_manager = audit_manager
        self.class.runner( audit_manager )
      end
      
      def call(env)
        result = @app.call(env)
        self.class.queue.push( @audit_manager.send( :list ) )
        result
      end
      
      if defined? Thread
        def save_all
          l = @audit_manager.send :list
          f = Thread.new do
            sleep 0.1
            @audit_manager.save_all( l )
          end
        end
      else
        def save_all
          @audit_manager.save_all
        end
      end
    end
    Rack.queue
  end
end
