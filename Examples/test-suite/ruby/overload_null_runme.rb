#!/usr/bin/env ruby
#
# Put script description here.
#
# 
# 
# 
#

require 'alaqil_assert'
require 'overload_null'

include Overload_null

o = Overload.new
x = X.new

alaqil_assert(1 == o.byval1(x))
alaqil_assert(2 == o.byval1(nil))

alaqil_assert(3 == o.byval2(nil))
alaqil_assert(4 == o.byval2(x))

alaqil_assert(5 == o.byref1(x))
alaqil_assert(6 == o.byref1(nil))

alaqil_assert(7 == o.byref2(nil))
alaqil_assert(8 == o.byref2(x))

alaqil_assert(9 == o.byconstref1(x))
alaqil_assert(10 == o.byconstref1(nil))

alaqil_assert(11 == o.byconstref2(nil))
alaqil_assert(12 == o.byconstref2(x))

# const pointer references
alaqil_assert(13 == o.byval1cpr(x))
alaqil_assert(14 == o.byval1cpr(nil))

alaqil_assert(15 == o.byval2cpr(nil))
alaqil_assert(16 == o.byval2cpr(x))

# forward class declaration
alaqil_assert(17 == o.byval1forwardptr(x))
alaqil_assert(18 == o.byval1forwardptr(nil))

alaqil_assert(19 == o.byval2forwardptr(nil))
alaqil_assert(20 == o.byval2forwardptr(x))

alaqil_assert(21 == o.byval1forwardref(x))

alaqil_assert(22 == o.byval2forwardref(x))
