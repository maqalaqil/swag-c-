/* -----------------------------------------------------------------------------
 * std_except.i
 *
 * Typemaps used by the STL wrappers that throw exceptions. These typemaps are
 * used when methods are declared with an STL exception specification, such as
 *   size_t at() const throw (std::out_of_range);
 * ----------------------------------------------------------------------------- */

%{
#include <typeinfo>
#include <stdexcept>
%}

namespace std
{
  %ignore exception;
  struct exception {};
}

%typemap(throws, canthrow=1) std::bad_cast          "alaqil_DSetPendingException(alaqil_DException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::bad_exception     "alaqil_DSetPendingException(alaqil_DException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::domain_error      "alaqil_DSetPendingException(alaqil_DException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::exception         "alaqil_DSetPendingException(alaqil_DException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::invalid_argument  "alaqil_DSetPendingException(alaqil_DIllegalArgumentException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::length_error      "alaqil_DSetPendingException(alaqil_DNoSuchElementException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::logic_error       "alaqil_DSetPendingException(alaqil_DException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::out_of_range      "alaqil_DSetPendingException(alaqil_DNoSuchElementException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::overflow_error    "alaqil_DSetPendingException(alaqil_DException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::range_error       "alaqil_DSetPendingException(alaqil_DException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::runtime_error     "alaqil_DSetPendingException(alaqil_DException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::underflow_error   "alaqil_DSetPendingException(alaqil_DException, $1.what());\n return $null;"

