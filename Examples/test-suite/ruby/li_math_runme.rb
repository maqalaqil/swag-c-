#!/usr/bin/env ruby
#
# li_math.i tests
#
#

require 'alaqil_assert'
require 'li_math'

alaqil_assert_each_line <<EOF
Li_math.cos(-5) == Math.cos(-5)
Li_math.sin(-5) == Math.sin(-5)
EOF
