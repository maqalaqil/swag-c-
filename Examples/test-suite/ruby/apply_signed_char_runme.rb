#!/usr/bin/env ruby
#
# Put script description here.
#
# 
# 
# 
#

require 'alaqil_assert'
require 'apply_signed_char'

include Apply_signed_char


['CharValFunction', 'CCharValFunction', 'CCharRefFunction'].each do |m|
  [ 3, -3 ].each do |v|
    val = send( m, v )
    alaqil_assert( "v == val", binding, "for #{m}")
  end
end

{ 'globalchar' => -109,
  'globalconstchar' => -110,
}.each do |k,v|
  val = Apply_signed_char.send( k )
  alaqil_assert( "v == val", binding, "for #{k}")
end


a = DirectorTest.new

['CharValFunction', 'CCharValFunction', 'CCharRefFunction'].each do |m|
  [ 3, -3 ].each do |v|
    val = a.send( m, v )
    alaqil_assert( "v == val", binding, "for DirectorTest.#{m}")
  end
end

{ 'memberchar' => -111,
  'memberconstchar' => -112,
}.each do |k,v|
  val = a.send( k )
  alaqil_assert( "v == val", binding, "for #{k}")
end
