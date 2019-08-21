#!/usr/bin/env ruby
#
# Runtime tests for ruby_alias_method.i
#

require 'alaqil_assert'
require 'ruby_alias_method'

include Ruby_alias_method

expected_name = "Chester Tester"
syn = Synonym.new(expected_name)

alaqil_assert(syn.getMyName() == expected_name, msg: "getMyName not working as expected")
alaqil_assert(syn.nickname() == expected_name, msg: "nickname not working as expected")
alaqil_assert(syn.fullname() == expected_name, msg: "fullname not working as expected")

if syn.method(:nickname).respond_to?(:original_name)
  alaqil_assert_equal_simple(syn.method(:nickname).original_name, :getMyName)
  alaqil_assert_equal_simple(syn.method(:fullname).original_name, :getMyName)
else
  alaqil_assert(syn.method(:nickname) == syn.method(:getMyName))
  alaqil_assert(syn.method(:fullname) == syn.method(:getMyName))
end
