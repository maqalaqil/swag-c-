/* -----------------------------------------------------------------------------
 * javahead.swg
 *
 * Java support code
 * ----------------------------------------------------------------------------- */


/* JNI function calls require different calling conventions for C and C++. These JCALL macros are used so 
 * that the same typemaps can be used for generating code for both C and C++. The alaqil preprocessor can expand
 * the macros thereby generating the correct calling convention. It is thus essential that all typemaps that
 * use the macros are not within %{ %} brackets as they won't be run through the alaqil preprocessor. */
#ifdef __cplusplus
#   define JCALL0(func, jenv) jenv->func()
#   define JCALL1(func, jenv, ar1) jenv->func(ar1)
#   define JCALL2(func, jenv, ar1, ar2) jenv->func(ar1, ar2)
#   define JCALL3(func, jenv, ar1, ar2, ar3) jenv->func(ar1, ar2, ar3)
#   define JCALL4(func, jenv, ar1, ar2, ar3, ar4) jenv->func(ar1, ar2, ar3, ar4)
#   define JCALL5(func, jenv, ar1, ar2, ar3, ar4, ar5) jenv->func(ar1, ar2, ar3, ar4, ar5)
#   define JCALL6(func, jenv, ar1, ar2, ar3, ar4, ar5, ar6) jenv->func(ar1, ar2, ar3, ar4, ar5, ar6)
#   define JCALL7(func, jenv, ar1, ar2, ar3, ar4, ar5, ar6, ar7) jenv->func(ar1, ar2, ar3, ar4, ar5, ar6, ar7)
#else
#   define JCALL0(func, jenv) (*jenv)->func(jenv)
#   define JCALL1(func, jenv, ar1) (*jenv)->func(jenv, ar1)
#   define JCALL2(func, jenv, ar1, ar2) (*jenv)->func(jenv, ar1, ar2)
#   define JCALL3(func, jenv, ar1, ar2, ar3) (*jenv)->func(jenv, ar1, ar2, ar3)
#   define JCALL4(func, jenv, ar1, ar2, ar3, ar4) (*jenv)->func(jenv, ar1, ar2, ar3, ar4)
#   define JCALL5(func, jenv, ar1, ar2, ar3, ar4, ar5) (*jenv)->func(jenv, ar1, ar2, ar3, ar4, ar5)
#   define JCALL6(func, jenv, ar1, ar2, ar3, ar4, ar5, ar6) (*jenv)->func(jenv, ar1, ar2, ar3, ar4, ar5, ar6)
#   define JCALL7(func, jenv, ar1, ar2, ar3, ar4, ar5, ar6, ar7) (*jenv)->func(jenv, ar1, ar2, ar3, ar4, ar5, ar6, ar7)
#endif

%insert(runtime) %{
/* Fix for jlong on some versions of gcc on Windows */
#if defined(__GNUC__) && !defined(__INTEL_COMPILER)
  typedef long long __int64;
#endif

/* Fix for jlong on 64-bit x86 Solaris */
#if defined(__x86_64)
# ifdef _LP64
#   undef _LP64
# endif
#endif

#include <jni.h>
#include <stdlib.h>
#include <string.h>
%}

%insert(runtime) %{
/* Support for throwing Java exceptions */
typedef enum {
  alaqil_JavaOutOfMemoryError = 1, 
  alaqil_JavaIOException, 
  alaqil_JavaRuntimeException, 
  alaqil_JavaIndexOutOfBoundsException,
  alaqil_JavaArithmeticException,
  alaqil_JavaIllegalArgumentException,
  alaqil_JavaNullPointerException,
  alaqil_JavaDirectorPureVirtual,
  alaqil_JavaUnknownError
} alaqil_JavaExceptionCodes;

typedef struct {
  alaqil_JavaExceptionCodes code;
  const char *java_exception;
} alaqil_JavaExceptions_t;
%}

%insert(runtime) {
static void alaqilUNUSED alaqil_JavaThrowException(JNIEnv *jenv, alaqil_JavaExceptionCodes code, const char *msg) {
  jclass excep;
  static const alaqil_JavaExceptions_t java_exceptions[] = {
    { alaqil_JavaOutOfMemoryError, "java/lang/OutOfMemoryError" },
    { alaqil_JavaIOException, "java/io/IOException" },
    { alaqil_JavaRuntimeException, "java/lang/RuntimeException" },
    { alaqil_JavaIndexOutOfBoundsException, "java/lang/IndexOutOfBoundsException" },
    { alaqil_JavaArithmeticException, "java/lang/ArithmeticException" },
    { alaqil_JavaIllegalArgumentException, "java/lang/IllegalArgumentException" },
    { alaqil_JavaNullPointerException, "java/lang/NullPointerException" },
    { alaqil_JavaDirectorPureVirtual, "java/lang/RuntimeException" },
    { alaqil_JavaUnknownError,  "java/lang/UnknownError" },
    { (alaqil_JavaExceptionCodes)0,  "java/lang/UnknownError" }
  };
  const alaqil_JavaExceptions_t *except_ptr = java_exceptions;

  while (except_ptr->code != code && except_ptr->code)
    except_ptr++;

  JCALL0(ExceptionClear, jenv);
  excep = JCALL1(FindClass, jenv, except_ptr->java_exception);
  if (excep)
    JCALL2(ThrowNew, jenv, excep, msg);
}
}

%insert(runtime) %{
/* Contract support */

#define alaqil_contract_assert(nullreturn, expr, msg) if (!(expr)) {alaqil_JavaThrowException(jenv, alaqil_JavaIllegalArgumentException, msg); return nullreturn; } else
%}
