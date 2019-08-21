#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'alaqil_assert'

require 'disown'

include Disown


a = A.new
b = B.new
b.acquire(a)

