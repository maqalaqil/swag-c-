/* -----------------------------------------------------------------------------
 * csharphead.swg
 *
 * Support code for exceptions if the alaqil_CSHARP_NO_EXCEPTION_HELPER is not defined
 * Support code for strings if the alaqil_CSHARP_NO_STRING_HELPER is not defined
 * ----------------------------------------------------------------------------- */

%insert(runtime) %{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
%}

#if !defined(alaqil_CSHARP_NO_EXCEPTION_HELPER)
%insert(runtime) %{
/* Support for throwing C# exceptions from C/C++. There are two types: 
 * Exceptions that take a message and ArgumentExceptions that take a message and a parameter name. */
typedef enum {
  alaqil_CSharpApplicationException,
  alaqil_CSharpArithmeticException,
  alaqil_CSharpDivideByZeroException,
  alaqil_CSharpIndexOutOfRangeException,
  alaqil_CSharpInvalidCastException,
  alaqil_CSharpInvalidOperationException,
  alaqil_CSharpIOException,
  alaqil_CSharpNullReferenceException,
  alaqil_CSharpOutOfMemoryException,
  alaqil_CSharpOverflowException,
  alaqil_CSharpSystemException
} alaqil_CSharpExceptionCodes;

typedef enum {
  alaqil_CSharpArgumentException,
  alaqil_CSharpArgumentNullException,
  alaqil_CSharpArgumentOutOfRangeException
} alaqil_CSharpExceptionArgumentCodes;

typedef void (alaqilSTDCALL* alaqil_CSharpExceptionCallback_t)(const char *);
typedef void (alaqilSTDCALL* alaqil_CSharpExceptionArgumentCallback_t)(const char *, const char *);

typedef struct {
  alaqil_CSharpExceptionCodes code;
  alaqil_CSharpExceptionCallback_t callback;
} alaqil_CSharpException_t;

typedef struct {
  alaqil_CSharpExceptionArgumentCodes code;
  alaqil_CSharpExceptionArgumentCallback_t callback;
} alaqil_CSharpExceptionArgument_t;

static alaqil_CSharpException_t alaqil_csharp_exceptions[] = {
  { alaqil_CSharpApplicationException, NULL },
  { alaqil_CSharpArithmeticException, NULL },
  { alaqil_CSharpDivideByZeroException, NULL },
  { alaqil_CSharpIndexOutOfRangeException, NULL },
  { alaqil_CSharpInvalidCastException, NULL },
  { alaqil_CSharpInvalidOperationException, NULL },
  { alaqil_CSharpIOException, NULL },
  { alaqil_CSharpNullReferenceException, NULL },
  { alaqil_CSharpOutOfMemoryException, NULL },
  { alaqil_CSharpOverflowException, NULL },
  { alaqil_CSharpSystemException, NULL }
};

static alaqil_CSharpExceptionArgument_t alaqil_csharp_exceptions_argument[] = {
  { alaqil_CSharpArgumentException, NULL },
  { alaqil_CSharpArgumentNullException, NULL },
  { alaqil_CSharpArgumentOutOfRangeException, NULL }
};

static void alaqilUNUSED alaqil_CSharpSetPendingException(alaqil_CSharpExceptionCodes code, const char *msg) {
  alaqil_CSharpExceptionCallback_t callback = alaqil_csharp_exceptions[alaqil_CSharpApplicationException].callback;
  if ((size_t)code < sizeof(alaqil_csharp_exceptions)/sizeof(alaqil_CSharpException_t)) {
    callback = alaqil_csharp_exceptions[code].callback;
  }
  callback(msg);
}

static void alaqilUNUSED alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpExceptionArgumentCodes code, const char *msg, const char *param_name) {
  alaqil_CSharpExceptionArgumentCallback_t callback = alaqil_csharp_exceptions_argument[alaqil_CSharpArgumentException].callback;
  if ((size_t)code < sizeof(alaqil_csharp_exceptions_argument)/sizeof(alaqil_CSharpExceptionArgument_t)) {
    callback = alaqil_csharp_exceptions_argument[code].callback;
  }
  callback(msg, param_name);
}
%}

%insert(runtime) %{
#ifdef __cplusplus
extern "C" 
#endif
alaqilEXPORT void alaqilSTDCALL alaqilRegisterExceptionCallbacks_$module(
                                                alaqil_CSharpExceptionCallback_t applicationCallback,
                                                alaqil_CSharpExceptionCallback_t arithmeticCallback,
                                                alaqil_CSharpExceptionCallback_t divideByZeroCallback, 
                                                alaqil_CSharpExceptionCallback_t indexOutOfRangeCallback, 
                                                alaqil_CSharpExceptionCallback_t invalidCastCallback,
                                                alaqil_CSharpExceptionCallback_t invalidOperationCallback,
                                                alaqil_CSharpExceptionCallback_t ioCallback,
                                                alaqil_CSharpExceptionCallback_t nullReferenceCallback,
                                                alaqil_CSharpExceptionCallback_t outOfMemoryCallback, 
                                                alaqil_CSharpExceptionCallback_t overflowCallback, 
                                                alaqil_CSharpExceptionCallback_t systemCallback) {
  alaqil_csharp_exceptions[alaqil_CSharpApplicationException].callback = applicationCallback;
  alaqil_csharp_exceptions[alaqil_CSharpArithmeticException].callback = arithmeticCallback;
  alaqil_csharp_exceptions[alaqil_CSharpDivideByZeroException].callback = divideByZeroCallback;
  alaqil_csharp_exceptions[alaqil_CSharpIndexOutOfRangeException].callback = indexOutOfRangeCallback;
  alaqil_csharp_exceptions[alaqil_CSharpInvalidCastException].callback = invalidCastCallback;
  alaqil_csharp_exceptions[alaqil_CSharpInvalidOperationException].callback = invalidOperationCallback;
  alaqil_csharp_exceptions[alaqil_CSharpIOException].callback = ioCallback;
  alaqil_csharp_exceptions[alaqil_CSharpNullReferenceException].callback = nullReferenceCallback;
  alaqil_csharp_exceptions[alaqil_CSharpOutOfMemoryException].callback = outOfMemoryCallback;
  alaqil_csharp_exceptions[alaqil_CSharpOverflowException].callback = overflowCallback;
  alaqil_csharp_exceptions[alaqil_CSharpSystemException].callback = systemCallback;
}

#ifdef __cplusplus
extern "C" 
#endif
alaqilEXPORT void alaqilSTDCALL alaqilRegisterExceptionArgumentCallbacks_$module(
                                                alaqil_CSharpExceptionArgumentCallback_t argumentCallback,
                                                alaqil_CSharpExceptionArgumentCallback_t argumentNullCallback,
                                                alaqil_CSharpExceptionArgumentCallback_t argumentOutOfRangeCallback) {
  alaqil_csharp_exceptions_argument[alaqil_CSharpArgumentException].callback = argumentCallback;
  alaqil_csharp_exceptions_argument[alaqil_CSharpArgumentNullException].callback = argumentNullCallback;
  alaqil_csharp_exceptions_argument[alaqil_CSharpArgumentOutOfRangeException].callback = argumentOutOfRangeCallback;
}
%}

%pragma(csharp) imclasscode=%{
  protected class alaqilExceptionHelper {

    public delegate void ExceptionDelegate(string message);
    public delegate void ExceptionArgumentDelegate(string message, string paramName);

    static ExceptionDelegate applicationDelegate = new ExceptionDelegate(SetPendingApplicationException);
    static ExceptionDelegate arithmeticDelegate = new ExceptionDelegate(SetPendingArithmeticException);
    static ExceptionDelegate divideByZeroDelegate = new ExceptionDelegate(SetPendingDivideByZeroException);
    static ExceptionDelegate indexOutOfRangeDelegate = new ExceptionDelegate(SetPendingIndexOutOfRangeException);
    static ExceptionDelegate invalidCastDelegate = new ExceptionDelegate(SetPendingInvalidCastException);
    static ExceptionDelegate invalidOperationDelegate = new ExceptionDelegate(SetPendingInvalidOperationException);
    static ExceptionDelegate ioDelegate = new ExceptionDelegate(SetPendingIOException);
    static ExceptionDelegate nullReferenceDelegate = new ExceptionDelegate(SetPendingNullReferenceException);
    static ExceptionDelegate outOfMemoryDelegate = new ExceptionDelegate(SetPendingOutOfMemoryException);
    static ExceptionDelegate overflowDelegate = new ExceptionDelegate(SetPendingOverflowException);
    static ExceptionDelegate systemDelegate = new ExceptionDelegate(SetPendingSystemException);

    static ExceptionArgumentDelegate argumentDelegate = new ExceptionArgumentDelegate(SetPendingArgumentException);
    static ExceptionArgumentDelegate argumentNullDelegate = new ExceptionArgumentDelegate(SetPendingArgumentNullException);
    static ExceptionArgumentDelegate argumentOutOfRangeDelegate = new ExceptionArgumentDelegate(SetPendingArgumentOutOfRangeException);

    [global::System.Runtime.InteropServices.DllImport("$dllimport", EntryPoint="alaqilRegisterExceptionCallbacks_$module")]
    public static extern void alaqilRegisterExceptionCallbacks_$module(
                                ExceptionDelegate applicationDelegate,
                                ExceptionDelegate arithmeticDelegate,
                                ExceptionDelegate divideByZeroDelegate, 
                                ExceptionDelegate indexOutOfRangeDelegate, 
                                ExceptionDelegate invalidCastDelegate,
                                ExceptionDelegate invalidOperationDelegate,
                                ExceptionDelegate ioDelegate,
                                ExceptionDelegate nullReferenceDelegate,
                                ExceptionDelegate outOfMemoryDelegate, 
                                ExceptionDelegate overflowDelegate, 
                                ExceptionDelegate systemExceptionDelegate);

    [global::System.Runtime.InteropServices.DllImport("$dllimport", EntryPoint="alaqilRegisterExceptionArgumentCallbacks_$module")]
    public static extern void alaqilRegisterExceptionCallbacksArgument_$module(
                                ExceptionArgumentDelegate argumentDelegate,
                                ExceptionArgumentDelegate argumentNullDelegate,
                                ExceptionArgumentDelegate argumentOutOfRangeDelegate);

    static void SetPendingApplicationException(string message) {
      alaqilPendingException.Set(new global::System.ApplicationException(message, alaqilPendingException.Retrieve()));
    }
    static void SetPendingArithmeticException(string message) {
      alaqilPendingException.Set(new global::System.ArithmeticException(message, alaqilPendingException.Retrieve()));
    }
    static void SetPendingDivideByZeroException(string message) {
      alaqilPendingException.Set(new global::System.DivideByZeroException(message, alaqilPendingException.Retrieve()));
    }
    static void SetPendingIndexOutOfRangeException(string message) {
      alaqilPendingException.Set(new global::System.IndexOutOfRangeException(message, alaqilPendingException.Retrieve()));
    }
    static void SetPendingInvalidCastException(string message) {
      alaqilPendingException.Set(new global::System.InvalidCastException(message, alaqilPendingException.Retrieve()));
    }
    static void SetPendingInvalidOperationException(string message) {
      alaqilPendingException.Set(new global::System.InvalidOperationException(message, alaqilPendingException.Retrieve()));
    }
    static void SetPendingIOException(string message) {
      alaqilPendingException.Set(new global::System.IO.IOException(message, alaqilPendingException.Retrieve()));
    }
    static void SetPendingNullReferenceException(string message) {
      alaqilPendingException.Set(new global::System.NullReferenceException(message, alaqilPendingException.Retrieve()));
    }
    static void SetPendingOutOfMemoryException(string message) {
      alaqilPendingException.Set(new global::System.OutOfMemoryException(message, alaqilPendingException.Retrieve()));
    }
    static void SetPendingOverflowException(string message) {
      alaqilPendingException.Set(new global::System.OverflowException(message, alaqilPendingException.Retrieve()));
    }
    static void SetPendingSystemException(string message) {
      alaqilPendingException.Set(new global::System.SystemException(message, alaqilPendingException.Retrieve()));
    }

    static void SetPendingArgumentException(string message, string paramName) {
      alaqilPendingException.Set(new global::System.ArgumentException(message, paramName, alaqilPendingException.Retrieve()));
    }
    static void SetPendingArgumentNullException(string message, string paramName) {
      global::System.Exception e = alaqilPendingException.Retrieve();
      if (e != null) message = message + " Inner Exception: " + e.Message;
      alaqilPendingException.Set(new global::System.ArgumentNullException(paramName, message));
    }
    static void SetPendingArgumentOutOfRangeException(string message, string paramName) {
      global::System.Exception e = alaqilPendingException.Retrieve();
      if (e != null) message = message + " Inner Exception: " + e.Message;
      alaqilPendingException.Set(new global::System.ArgumentOutOfRangeException(paramName, message));
    }

    static alaqilExceptionHelper() {
      alaqilRegisterExceptionCallbacks_$module(
                                applicationDelegate,
                                arithmeticDelegate,
                                divideByZeroDelegate,
                                indexOutOfRangeDelegate,
                                invalidCastDelegate,
                                invalidOperationDelegate,
                                ioDelegate,
                                nullReferenceDelegate,
                                outOfMemoryDelegate,
                                overflowDelegate,
                                systemDelegate);

      alaqilRegisterExceptionCallbacksArgument_$module(
                                argumentDelegate,
                                argumentNullDelegate,
                                argumentOutOfRangeDelegate);
    }
  }

  protected static alaqilExceptionHelper alaqilExceptionHelper = new alaqilExceptionHelper();

  public class alaqilPendingException {
    [global::System.ThreadStatic]
    private static global::System.Exception pendingException = null;
    private static int numExceptionsPending = 0;

    public static bool Pending {
      get {
        bool pending = false;
        if (numExceptionsPending > 0)
          if (pendingException != null)
            pending = true;
        return pending;
      } 
    }

    public static void Set(global::System.Exception e) {
      if (pendingException != null)
        throw new global::System.ApplicationException("FATAL: An earlier pending exception from unmanaged code was missed and thus not thrown (" + pendingException.ToString() + ")", e);
      pendingException = e;
      lock(typeof($imclassname)) {
        numExceptionsPending++;
      }
    }

    public static global::System.Exception Retrieve() {
      global::System.Exception e = null;
      if (numExceptionsPending > 0) {
        if (pendingException != null) {
          e = pendingException;
          pendingException = null;
          lock(typeof($imclassname)) {
            numExceptionsPending--;
          }
        }
      }
      return e;
    }
  }
%}
#endif // alaqil_CSHARP_NO_EXCEPTION_HELPER

#if !defined(alaqil_CSHARP_NO_STRING_HELPER)
%insert(runtime) %{
/* Callback for returning strings to C# without leaking memory */
typedef char * (alaqilSTDCALL* alaqil_CSharpStringHelperCallback)(const char *);
static alaqil_CSharpStringHelperCallback alaqil_csharp_string_callback = NULL;
%}

%pragma(csharp) imclasscode=%{
  protected class alaqilStringHelper {

    public delegate string alaqilStringDelegate(string message);
    static alaqilStringDelegate stringDelegate = new alaqilStringDelegate(CreateString);

    [global::System.Runtime.InteropServices.DllImport("$dllimport", EntryPoint="alaqilRegisterStringCallback_$module")]
    public static extern void alaqilRegisterStringCallback_$module(alaqilStringDelegate stringDelegate);

    static string CreateString(string cString) {
      return cString;
    }

    static alaqilStringHelper() {
      alaqilRegisterStringCallback_$module(stringDelegate);
    }
  }

  static protected alaqilStringHelper alaqilStringHelper = new alaqilStringHelper();
%}

%insert(runtime) %{
#ifdef __cplusplus
extern "C" 
#endif
alaqilEXPORT void alaqilSTDCALL alaqilRegisterStringCallback_$module(alaqil_CSharpStringHelperCallback callback) {
  alaqil_csharp_string_callback = callback;
}
%}
#endif // alaqil_CSHARP_NO_STRING_HELPER

#if !defined(alaqil_CSHARP_NO_IMCLASS_STATIC_CONSTRUCTOR)
// Ensure the class is not marked beforefieldinit
%pragma(csharp) imclasscode=%{
  static $imclassname() {
  }
%}
#endif

%insert(runtime) %{
/* Contract support */

#define alaqil_contract_assert(nullreturn, expr, msg) if (!(expr)) {alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentOutOfRangeException, msg, ""); return nullreturn; } else
%}
