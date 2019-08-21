/* -----------------------------------------------------------------------------
 * std_except.i
 *
 * Typemaps used by the STL wrappers that throw exceptions.
 * These typemaps are used when methods are declared with an STL exception specification, such as
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

%typemap(throws) std::bad_cast          "alaqil_JavaThrowException(jenv, alaqil_JavaRuntimeException, $1.what());\n return $null;"
%typemap(throws) std::bad_exception     "alaqil_JavaThrowException(jenv, alaqil_JavaRuntimeException, $1.what());\n return $null;"
%typemap(throws) std::domain_error      "alaqil_JavaThrowException(jenv, alaqil_JavaRuntimeException, $1.what());\n return $null;"
%typemap(throws) std::exception         "alaqil_JavaThrowException(jenv, alaqil_JavaRuntimeException, $1.what());\n return $null;"
%typemap(throws) std::invalid_argument  "alaqil_JavaThrowException(jenv, alaqil_JavaIllegalArgumentException, $1.what());\n return $null;"
%typemap(throws) std::length_error      "alaqil_JavaThrowException(jenv, alaqil_JavaIndexOutOfBoundsException, $1.what());\n return $null;"
%typemap(throws) std::logic_error       "alaqil_JavaThrowException(jenv, alaqil_JavaRuntimeException, $1.what());\n return $null;"
%typemap(throws) std::out_of_range      "alaqil_JavaThrowException(jenv, alaqil_JavaIndexOutOfBoundsException, $1.what());\n return $null;"
%typemap(throws) std::overflow_error    "alaqil_JavaThrowException(jenv, alaqil_JavaArithmeticException, $1.what());\n return $null;"
%typemap(throws) std::range_error       "alaqil_JavaThrowException(jenv, alaqil_JavaIndexOutOfBoundsException, $1.what());\n return $null;"
%typemap(throws) std::runtime_error     "alaqil_JavaThrowException(jenv, alaqil_JavaRuntimeException, $1.what());\n return $null;"
%typemap(throws) std::underflow_error   "alaqil_JavaThrowException(jenv, alaqil_JavaArithmeticException, $1.what());\n return $null;"

