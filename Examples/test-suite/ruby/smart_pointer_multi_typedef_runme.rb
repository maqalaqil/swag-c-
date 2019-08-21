#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'alaqil_assert'

require 'smart_pointer_multi_typedef'

include Smart_pointer_multi_typedef

f = Foo.new
b = Bar.new(f)
s = Spam.new(b)
g = Grok.new(b)

s.x = 3
raise RuntimeError if s.getx() != 3

g.x = 4
raise RuntimeError if g.getx() != 4
