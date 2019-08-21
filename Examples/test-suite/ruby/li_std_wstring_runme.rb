# -*- coding: utf-8 -*-
require 'alaqil_assert'
require 'li_std_wstring'

x = "abc"
alaqil_assert_equal("Li_std_wstring.test_wchar_overload(x)", "x", binding)
alaqil_assert_equal("Li_std_wstring.test_ccvalue(x)", "x", binding)
alaqil_assert_equal("Li_std_wstring.test_value(Li_std_wstring::Wstring.new(x))", "x", binding)

alaqil_assert_equal("Li_std_wstring.test_wchar_overload()", "nil", binding)

alaqil_assert_equal("Li_std_wstring.test_pointer(Li_std_wstring::Wstring.new(x))", "nil", binding)
alaqil_assert_equal("Li_std_wstring.test_const_pointer(Li_std_wstring::Wstring.new(x))", "nil", binding)
alaqil_assert_equal("Li_std_wstring.test_const_pointer(Li_std_wstring::Wstring.new(x))", "nil", binding)
alaqil_assert_equal("Li_std_wstring.test_reference(Li_std_wstring::Wstring.new(x))", "nil", binding)

x = "y"
alaqil_assert_equal("Li_std_wstring.test_value(x)", "x", binding)
a = Li_std_wstring::A.new(x)
alaqil_assert_equal("Li_std_wstring.test_value(a)", "x", binding)

x = "hello"
alaqil_assert_equal("Li_std_wstring.test_const_reference(x)", "x", binding)


alaqil_assert_equal("Li_std_wstring.test_pointer_out", "'x'", binding)
alaqil_assert_equal("Li_std_wstring.test_const_pointer_out", "'x'", binding)
alaqil_assert_equal("Li_std_wstring.test_reference_out()", "'x'", binding)

s = "abc"
alaqil_assert("Li_std_wstring.test_equal_abc(s)", binding)

begin
  Li_std_wstring.test_throw
rescue RuntimeError => e
  alaqil_assert_equal("e.message", "'x'", binding)
end

x = "abc\0def"
alaqil_assert_equal("Li_std_wstring.test_value(x)", "x", binding)
alaqil_assert_equal("Li_std_wstring.test_ccvalue(x)", '"abc"', binding)
alaqil_assert_equal("Li_std_wstring.test_wchar_overload(x)", '"abc"', binding)
