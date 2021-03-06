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
require 'cuba_api'
require 'ixtlan/audit/resource'
require 'ixtlan/audit/serializer'
module Ixtlan
  module Audit
    class Cuba < ::CubaAPI
      define do
        on get, 'last' do
          write Ixtlan::Audit::Audit.last
        end
        on get, :number do |number|
          write Ixtlan::Audit::Audit.get!( number.to_i )
        end
        on get do
          query = {}
          query[ :login ] = req[ :login ] if req[ :login ]
          query[ :path.like ] = '%' + req[ :path ] + '%' if req[ :path ]
          write Ixtlan::Audit::Audit.all( query ).reverse
        end
      end
    end
  end
end
