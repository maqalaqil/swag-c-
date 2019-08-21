#!/usr/bin/env ruby
#
# Put description here
#
# 
# 
# 
#

require 'alaqil_assert'

require 'enum_thorough'

include Enum_thorough

# Just test an in and out typemap for enum alaqilTYPE and const enum alaqilTYPE & typemaps
raise RuntimeError if speedTest4(SpeedClass::Slow) != SpeedClass::Slow
raise RuntimeError if speedTest5(SpeedClass::Slow) != SpeedClass::Slow

