#!/usr/bin/env ruby
#
#

require 'alaqil_assert'

require 'const_const'
include Const_const

alaqil_assert_each_line <<EOF
foo(1)  # 1 is unused
EOF


