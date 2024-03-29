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

%typemap(throws) std::bad_cast		%{_alaqil_gopanic($1.what());%}
%typemap(throws) std::bad_exception	%{_alaqil_gopanic($1.what());%}
%typemap(throws) std::domain_error	%{_alaqil_gopanic($1.what());%}
%typemap(throws) std::exception		%{_alaqil_gopanic($1.what());%}
%typemap(throws) std::invalid_argument	%{_alaqil_gopanic($1.what());%}
%typemap(throws) std::length_error	%{_alaqil_gopanic($1.what());%}
%typemap(throws) std::logic_error	%{_alaqil_gopanic($1.what());%}
%typemap(throws) std::out_of_range	%{_alaqil_gopanic($1.what());%}
%typemap(throws) std::overflow_error	%{_alaqil_gopanic($1.what());%}
%typemap(throws) std::range_error	%{_alaqil_gopanic($1.what());%}
%typemap(throws) std::runtime_error	%{_alaqil_gopanic($1.what());%}
%typemap(throws) std::underflow_error	%{_alaqil_gopanic($1.what());%}
