#!/usr/bin/env ruby
#
# Put script description here.
#
# 
# 
# 
#

require 'alaqil_assert'
require 'abstract_access'

include Abstract_access

begin
  a = A.new
rescue TypeError
  alaqil_assert(true, binding, 'A.new')
end

begin
  b = B.new
rescue TypeError
  alaqil_assert(true, binding, 'B.new')
end

begin
  c = C.new
rescue TypeError
  alaqil_assert(true, binding, 'C.new')
end

alaqil_assert( 'D.new' )

