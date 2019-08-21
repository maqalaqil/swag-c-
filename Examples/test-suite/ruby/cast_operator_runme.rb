#!/usr/bin/env ruby
#
# Put script description here.
#
# 
# 
# 
#

require 'alaqil_assert'
require 'cast_operator'
include Cast_operator

a = A.new
t = a.tochar

alaqil_assert( t == 'hi' )
