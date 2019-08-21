/* -----------------------------------------------------------------------------
 * modula3head.swg
 *
 * Modula3 support code
 * ----------------------------------------------------------------------------- */

%insert(runtime) %{

#include <stdlib.h>
#include <string.h>
#include <stdio.h>
%}

#if 0
%insert(runtime) %{
/* Support for throwing Modula3 exceptions */
typedef enum {
  alaqil_JavaOutOfMemoryError = 1, 
  alaqil_JavaIOException, 
  alaqil_JavaRuntimeException, 
  alaqil_JavaIndexOutOfBoundsException,
  alaqil_JavaArithmeticException,
  alaqil_JavaIllegalArgumentException,
  alaqil_JavaNullPointerException,
  alaqil_JavaUnknownError
} alaqil_JavaExceptionCodes;

typedef struct {
  alaqil_JavaExceptionCodes code;
  const char *java_exception;
} alaqil_JavaExceptions_t;

#if defined(alaqil_NOINCLUDE)
void alaqil_JavaThrowException(JNIEnv *jenv, alaqil_JavaExceptionCodes code, const char *msg);
#else
%}
%insert(runtime) {
void alaqil_JavaThrowException(JNIEnv *jenv, alaqil_JavaExceptionCodes code, const char *msg) {
  jclass excep;
  static const alaqil_JavaExceptions_t java_exceptions[] = {
    { alaqil_JavaOutOfMemoryError, "java/lang/OutOfMemoryError" },
    { alaqil_JavaIOException, "java/io/IOException" },
    { alaqil_JavaRuntimeException, "java/lang/RuntimeException" },
    { alaqil_JavaIndexOutOfBoundsException, "java/lang/IndexOutOfBoundsException" },
    { alaqil_JavaArithmeticException, "java/lang/ArithmeticException" },
    { alaqil_JavaIllegalArgumentException, "java/lang/IllegalArgumentException" },
    { alaqil_JavaNullPointerException, "java/lang/NullPointerException" },
    { alaqil_JavaUnknownError,  "java/lang/UnknownError" },
    { (alaqil_JavaExceptionCodes)0,  "java/lang/UnknownError" } };
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
#endif
%}
#endif
