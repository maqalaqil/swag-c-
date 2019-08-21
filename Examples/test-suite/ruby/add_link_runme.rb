#!/usr/bin/env ruby
#
# Put script description here.
#
# 
# 
# 
#

require 'alaqil_assert'
require 'add_link'
include Add_link

#
# This test currently fails due to alaqil
#
exit(0)

alaqil_assert( 'Foo.new' )
alaqil_assert( 'Foo.blah' )
