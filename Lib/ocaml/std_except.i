%{
#include <typeinfo>
#include <stdexcept>
%}

namespace std
{
  %ignore exception;
  struct exception {};
}

%typemap(throws) std::bad_cast          "alaqil_OCamlThrowException(alaqil_OCamlRuntimeException, $1.what());"
%typemap(throws) std::bad_exception     "alaqil_OCamlThrowException(alaqil_OCamlRuntimeException, $1.what());"
%typemap(throws) std::domain_error      "alaqil_OCamlThrowException(alaqil_OCamlRuntimeException, $1.what());"
%typemap(throws) std::exception         "alaqil_OCamlThrowException(alaqil_OCamlRuntimeException, $1.what());"
%typemap(throws) std::invalid_argument  "alaqil_OCamlThrowException(alaqil_OCamlIllegalArgumentException, $1.what());"
%typemap(throws) std::length_error      "alaqil_OCamlThrowException(alaqil_OCamlIndexOutOfBoundsException, $1.what());"
%typemap(throws) std::logic_error       "alaqil_OCamlThrowException(alaqil_OCamlRuntimeException, $1.what());"
%typemap(throws) std::out_of_range      "alaqil_OCamlThrowException(alaqil_OCamlIndexOutOfBoundsException, $1.what());"
%typemap(throws) std::overflow_error    "alaqil_OCamlThrowException(alaqil_OCamlArithmeticException, $1.what());"
%typemap(throws) std::range_error       "alaqil_OCamlThrowException(alaqil_OCamlIndexOutOfBoundsException, $1.what());"
%typemap(throws) std::runtime_error     "alaqil_OCamlThrowException(alaqil_OCamlRuntimeException, $1.what());"
%typemap(throws) std::underflow_error   "alaqil_OCamlThrowException(alaqil_OCamlArithmeticException, $1.what());"
