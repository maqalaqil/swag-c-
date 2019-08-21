#!/usr/bin/env ruby

require 'alaqil_assert'
require 'li_std_vector_enum'
include Li_std_vector_enum

ev = EnumVector.new()

alaqil_assert(ev.nums[0] == 10)
alaqil_assert(ev.nums[1] == 20)
alaqil_assert(ev.nums[2] == 30)

it = ev.nums.begin
v = it.value()
alaqil_assert(v == 10)
it.next()
v = it.value()
alaqil_assert(v == 20)

expected = 10 
ev.nums.each do|val|
  alaqil_assert(val == expected)
  expected += 10
end

