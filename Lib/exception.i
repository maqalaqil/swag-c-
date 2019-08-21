/* -----------------------------------------------------------------------------
 * exception.i
 *
 * alaqil library file providing language independent exception handling
 * ----------------------------------------------------------------------------- */

#if defined(alaqilUTL)
#error "This version of exception.i should not be used"
#endif


%insert("runtime") "alaqilerrors.swg"


#ifdef alaqilPHP7
%{
#include "zend_exceptions.h"
#define alaqil_exception(code, msg) do { zend_throw_exception(NULL, (char*)msg, code); goto thrown; } while (0)
%}
#endif

#ifdef alaqilGUILE
%{
  alaqilINTERN void alaqil_exception_ (int code, const char *msg,
                               const char *subr) {
#define ERROR(scmerr)					\
	scm_error(scm_from_locale_string((char *) (scmerr)),	\
		  (char *) subr, (char *) msg,		\
		  SCM_EOL, SCM_BOOL_F)
#define MAP(alaqilerr, scmerr)			\
	case alaqilerr:				\
	  ERROR(scmerr);			\
	  break
    switch (code) {
      MAP(alaqil_MemoryError,	"alaqil-memory-error");
      MAP(alaqil_IOError,		"alaqil-io-error");
      MAP(alaqil_RuntimeError,	"alaqil-runtime-error");
      MAP(alaqil_IndexError,	"alaqil-index-error");
      MAP(alaqil_TypeError,	"alaqil-type-error");
      MAP(alaqil_DivisionByZero,	"alaqil-division-by-zero");
      MAP(alaqil_OverflowError,	"alaqil-overflow-error");
      MAP(alaqil_SyntaxError,	"alaqil-syntax-error");
      MAP(alaqil_ValueError,	"alaqil-value-error");
      MAP(alaqil_SystemError,	"alaqil-system-error");
    default:
      ERROR("alaqil-error");
    }
#undef ERROR
#undef MAP
  }

#define alaqil_exception(a,b) alaqil_exception_(a, b, FUNC_NAME)
%}
#endif

#ifdef alaqilMZSCHEME

%{
alaqilINTERN void alaqil_exception_ (int code, const char *msg) {
#define ERROR(errname)				\
	scheme_signal_error(errname " (%s)", msg);
#define MAP(alaqilerr, errname)			\
	case alaqilerr:				\
	  ERROR(errname);			\
	  break
    switch (code) {
      MAP(alaqil_MemoryError,	"alaqil-memory-error");
      MAP(alaqil_IOError,		"alaqil-io-error");
      MAP(alaqil_RuntimeError,	"alaqil-runtime-error");
      MAP(alaqil_IndexError,	"alaqil-index-error");
      MAP(alaqil_TypeError,	"alaqil-type-error");
      MAP(alaqil_DivisionByZero,	"alaqil-division-by-zero");
      MAP(alaqil_OverflowError,	"alaqil-overflow-error");
      MAP(alaqil_SyntaxError,	"alaqil-syntax-error");
      MAP(alaqil_ValueError,	"alaqil-value-error");
      MAP(alaqil_SystemError,	"alaqil-system-error");
    default:
      ERROR("alaqil-error");
    }
#undef ERROR
#undef MAP
  }

#define alaqil_exception(a,b) alaqil_exception_(a, b)
%}
#endif

#ifdef alaqilJAVA
%{
alaqilINTERN void alaqil_JavaException(JNIEnv *jenv, int code, const char *msg) {
  alaqil_JavaExceptionCodes exception_code = alaqil_JavaUnknownError;
  switch(code) {
  case alaqil_MemoryError:
    exception_code = alaqil_JavaOutOfMemoryError;
    break;
  case alaqil_IOError:
    exception_code = alaqil_JavaIOException;
    break;
  case alaqil_SystemError:
  case alaqil_RuntimeError:
    exception_code = alaqil_JavaRuntimeException;
    break;
  case alaqil_OverflowError:
  case alaqil_IndexError:
    exception_code = alaqil_JavaIndexOutOfBoundsException;
    break;
  case alaqil_DivisionByZero:
    exception_code = alaqil_JavaArithmeticException;
    break;
  case alaqil_SyntaxError:
  case alaqil_ValueError:
  case alaqil_TypeError:
    exception_code = alaqil_JavaIllegalArgumentException;
    break;
  case alaqil_UnknownError:
  default:
    exception_code = alaqil_JavaUnknownError;
    break;
  }
  alaqil_JavaThrowException(jenv, exception_code, msg);
}
%}

#define alaqil_exception(code, msg)\
{ alaqil_JavaException(jenv, code, msg); return $null; }
#endif // alaqilJAVA

#ifdef alaqilOCAML
%{
alaqilINTERN void alaqil_OCamlException(int code, const char *msg) {
  CAMLparam0();

  alaqil_OCamlExceptionCodes exception_code = alaqil_OCamlUnknownError;
  switch (code) {
  case alaqil_DivisionByZero:
    exception_code = alaqil_OCamlArithmeticException;
    break;
  case alaqil_IndexError:
    exception_code = alaqil_OCamlIndexOutOfBoundsException;
    break;
  case alaqil_IOError:
  case alaqil_SystemError:
    exception_code = alaqil_OCamlSystemException;
    break;
  case alaqil_MemoryError:
    exception_code = alaqil_OCamlOutOfMemoryError;
    break;
  case alaqil_OverflowError:
    exception_code = alaqil_OCamlOverflowException;
    break;
  case alaqil_RuntimeError:
    exception_code = alaqil_OCamlRuntimeException;
    break;
  case alaqil_SyntaxError:
  case alaqil_TypeError:
  case alaqil_ValueError:
    exception_code = alaqil_OCamlIllegalArgumentException;
    break;
  case alaqil_UnknownError:
  default:
    exception_code = alaqil_OCamlUnknownError;
    break;
  }
  alaqil_OCamlThrowException(exception_code, msg);
  CAMLreturn0;
}
#define alaqil_exception(code, msg) alaqil_OCamlException(code, msg)
%}
#endif


#ifdef alaqilCSHARP
%{
alaqilINTERN void alaqil_CSharpException(int code, const char *msg) {
  if (code == alaqil_ValueError) {
    alaqil_CSharpExceptionArgumentCodes exception_code = alaqil_CSharpArgumentOutOfRangeException;
    alaqil_CSharpSetPendingExceptionArgument(exception_code, msg, 0);
  } else {
    alaqil_CSharpExceptionCodes exception_code = alaqil_CSharpApplicationException;
    switch(code) {
    case alaqil_MemoryError:
      exception_code = alaqil_CSharpOutOfMemoryException;
      break;
    case alaqil_IndexError:
      exception_code = alaqil_CSharpIndexOutOfRangeException;
      break;
    case alaqil_DivisionByZero:
      exception_code = alaqil_CSharpDivideByZeroException;
      break;
    case alaqil_IOError:
      exception_code = alaqil_CSharpIOException;
      break;
    case alaqil_OverflowError:
      exception_code = alaqil_CSharpOverflowException;
      break;
    case alaqil_RuntimeError:
    case alaqil_TypeError:
    case alaqil_SyntaxError:
    case alaqil_SystemError:
    case alaqil_UnknownError:
    default:
      exception_code = alaqil_CSharpApplicationException;
      break;
    }
    alaqil_CSharpSetPendingException(exception_code, msg);
  }
}
%}

#define alaqil_exception(code, msg)\
{ alaqil_CSharpException(code, msg); return $null; }
#endif // alaqilCSHARP

#ifdef alaqilLUA

%{
#define alaqil_exception(a,b)\
{ lua_pushfstring(L,"%s:%s",#a,b);alaqil_fail; }
%}

#endif // alaqilLUA

#ifdef alaqilD
%{
alaqilINTERN void alaqil_DThrowException(int code, const char *msg) {
  alaqil_DExceptionCodes exception_code;
  switch(code) {
  case alaqil_IndexError:
    exception_code = alaqil_DNoSuchElementException;
    break;
  case alaqil_IOError:
    exception_code = alaqil_DIOException;
    break;
  case alaqil_ValueError:
    exception_code = alaqil_DIllegalArgumentException;
    break;
  case alaqil_DivisionByZero:
  case alaqil_MemoryError:
  case alaqil_OverflowError:
  case alaqil_RuntimeError:
  case alaqil_TypeError:
  case alaqil_SyntaxError:
  case alaqil_SystemError:
  case alaqil_UnknownError:
  default:
    exception_code = alaqil_DException;
    break;
  }
  alaqil_DSetPendingException(exception_code, msg);
}
%}

#define alaqil_exception(code, msg)\
{ alaqil_DThrowException(code, msg); return $null; }
#endif // alaqilD

#ifdef __cplusplus
/*
  You can use the alaqil_CATCH_STDEXCEPT macro with the %exception
  directive as follows:

  %exception {
    try {
      $action
    }
    catch (my_except& e) {
      ...
    }
    alaqil_CATCH_STDEXCEPT // catch std::exception
    catch (...) {
     alaqil_exception(alaqil_UnknownError, "Unknown exception");
    }
  }
*/
%{
#include <typeinfo>
#include <stdexcept>
%}
%define alaqil_CATCH_STDEXCEPT
  /* catching std::exception  */
  catch (std::invalid_argument& e) {
    alaqil_exception(alaqil_ValueError, e.what() );
  } catch (std::domain_error& e) {
    alaqil_exception(alaqil_ValueError, e.what() );
  } catch (std::overflow_error& e) {
    alaqil_exception(alaqil_OverflowError, e.what() );
  } catch (std::out_of_range& e) {
    alaqil_exception(alaqil_IndexError, e.what() );
  } catch (std::length_error& e) {
    alaqil_exception(alaqil_IndexError, e.what() );
  } catch (std::runtime_error& e) {
    alaqil_exception(alaqil_RuntimeError, e.what() );
  } catch (std::bad_cast& e) {
    alaqil_exception(alaqil_TypeError, e.what() );
  } catch (std::exception& e) {
    alaqil_exception(alaqil_SystemError, e.what() );
  }
%enddef
%define alaqil_CATCH_UNKNOWN
  catch (std::exception& e) {
    alaqil_exception(alaqil_SystemError, e.what() );
  }
  catch (...) {
    alaqil_exception(alaqil_UnknownError, "unknown exception");
  }
%enddef

/* rethrow the unknown exception */

#if defined(alaqilCSHARP) || defined(alaqilD)
%typemap(throws,noblock=1, canthrow=1) (...) {
  alaqil_exception(alaqil_RuntimeError,"unknown exception");
}
#else
%typemap(throws,noblock=1) (...) {
  alaqil_exception(alaqil_RuntimeError,"unknown exception");
}
#endif

#endif /* __cplusplus */

/* exception.i ends here */
