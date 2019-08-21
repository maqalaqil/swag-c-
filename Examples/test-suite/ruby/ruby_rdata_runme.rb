require 'alaqil_assert'
require 'ruby_rdata'

include Ruby_rdata

alaqil_assert_equal_simple(1, take_proc_or_cpp_obj_and_ret_1(Proc.new{}))
alaqil_assert_equal_simple(1, take_proc_or_cpp_obj_and_ret_1(C.new))
