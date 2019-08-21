#!/usr/bin/env ruby
#
# Put script description here.
#
# 
# 
# 
#

require 'alaqil_assert'
require 'apply_strings'

include Apply_strings

begin
  x = UcharPtr.new
  alaqil_assert( fail, "UcharPtr should not be defined")
rescue NameError
end

ptr = 'a'
['UCharFunction', 'SCharFunction', 'CUCharFunction',
 'CSCharFunction'].each do |m|
  val = Apply_strings.send(m, ptr)
  alaqil_assert( "val == ptr", binding )
end


['CharFunction', 'CCharFunction'].each do |m|
  begin
    val = Apply_strings.send(m, ptr)
    alaqil_assert( false, nil, "Apply_strings.#{m} should raise TypeError" )
  rescue TypeError
  end
end

ptr = 'a'
foo = DirectorTest.new
['UCharFunction', 'SCharFunction', 'CUCharFunction',
 'CSCharFunction'].each do |m|
  val = foo.send(m, ptr)
  alaqil_assert( "val == ptr", binding, "DirectorTest.#{m}" )
end


['CharFunction', 'CCharFunction'].each do |m|
  begin
    val = foo.send(m, ptr)
    alaqil_assert( false, nil, "DirectorTest.#{m} should raise TypeError" )
  rescue TypeError
  end
end


# ary = Apply_strings.DigitsGlobalB
# { 0 => 'A',
#   1 => 'B',
#   2 => 'B' }.each do |k,v|
#   val = ary[k]
#   alaqil_assert( val == v, "Apply_strings.DigitsGlobalB[#{k}] #{val} != #{v}")
# end
