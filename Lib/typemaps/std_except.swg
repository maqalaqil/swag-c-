%include <typemaps/exception.swg>

/* 
   Mark all of std exception classes as "exception classes" via
   the "exceptionclass" feature.
   
   If needed, you can disable it by using %noexceptionclass.
*/

%define %std_exception_map(Exception, Code)
  %exceptionclass  Exception; 
#if !defined(alaqil_STD_EXCEPTIONS_AS_CLASSES)
  %typemap(throws,noblock=1) Exception {
    alaqil_exception_fail(Code, $1.what());
  }
  %ignore Exception;
  struct Exception {
  };
#endif
%enddef

namespace std {
  %std_exception_map(bad_cast,           alaqil_TypeError);
  %std_exception_map(bad_exception,      alaqil_SystemError);
  %std_exception_map(domain_error,       alaqil_ValueError);
  %std_exception_map(exception,          alaqil_SystemError);
  %std_exception_map(invalid_argument,   alaqil_ValueError);
  %std_exception_map(length_error,       alaqil_IndexError);
  %std_exception_map(logic_error,        alaqil_RuntimeError);
  %std_exception_map(out_of_range,       alaqil_IndexError);
  %std_exception_map(overflow_error,     alaqil_OverflowError);
  %std_exception_map(range_error,        alaqil_OverflowError);
  %std_exception_map(runtime_error,      alaqil_RuntimeError);
  %std_exception_map(underflow_error,    alaqil_OverflowError);
}

%include <std/std_except.i>
