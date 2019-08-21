/* -----------------------------------------------------------------------------
 * dhead.swg
 *
 * Support code for exceptions if the alaqil_D_NO_EXCEPTION_HELPER is not defined
 * Support code for strings if the alaqil_D_NO_STRING_HELPER is not defined
 *
 * Support code for function pointers. ----------------------------------------------------------------------------- */

%insert(runtime) %{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* Contract support. */
#define alaqil_contract_assert(nullreturn, expr, msg) if (!(expr)) {alaqil_DSetPendingException(alaqil_DException, msg); return nullreturn; } else
%}


/*
 * Exception support code.
 */

#if !defined(alaqil_D_NO_EXCEPTION_HELPER)
%insert(runtime) %{
// Support for throwing D exceptions from C/C++.
typedef enum {
  alaqil_DException = 0,
  alaqil_DIllegalArgumentException,
  alaqil_DIllegalElementException,
  alaqil_DIOException,
  alaqil_DNoSuchElementException
} alaqil_DExceptionCodes;

typedef void (* alaqil_DExceptionCallback_t)(const char *);

typedef struct {
  alaqil_DExceptionCodes code;
  alaqil_DExceptionCallback_t callback;
} alaqil_DException_t;

static alaqil_DException_t alaqil_d_exceptions[] = {
  { alaqil_DException, NULL },
  { alaqil_DIllegalArgumentException, NULL },
  { alaqil_DIllegalElementException, NULL },
  { alaqil_DIOException, NULL },
  { alaqil_DNoSuchElementException, NULL }
};

static void alaqilUNUSED alaqil_DSetPendingException(alaqil_DExceptionCodes code, const char *msg) {
  if ((size_t)code < sizeof(alaqil_d_exceptions)/sizeof(alaqil_DException_t)) {
    alaqil_d_exceptions[code].callback(msg);
  } else {
    alaqil_d_exceptions[alaqil_DException].callback(msg);
  }
}

#ifdef __cplusplus
extern "C"
#endif
alaqilEXPORT void alaqilRegisterExceptionCallbacks_$module(
  alaqil_DExceptionCallback_t exceptionCallback,
  alaqil_DExceptionCallback_t illegalArgumentCallback,
  alaqil_DExceptionCallback_t illegalElementCallback,
  alaqil_DExceptionCallback_t ioCallback,
  alaqil_DExceptionCallback_t noSuchElementCallback) {
  alaqil_d_exceptions[alaqil_DException].callback = exceptionCallback;
  alaqil_d_exceptions[alaqil_DIllegalArgumentException].callback = illegalArgumentCallback;
  alaqil_d_exceptions[alaqil_DIllegalElementException].callback = illegalElementCallback;
  alaqil_d_exceptions[alaqil_DIOException].callback = ioCallback;
  alaqil_d_exceptions[alaqil_DNoSuchElementException].callback = noSuchElementCallback;
}
%}

#if (alaqil_D_VERSION == 1)
%pragma(d) imdmoduleimports=%{
// Exception throwing support currently requires Tango, but there is no reason
// why it could not support Phobos.
static import tango.core.Exception;
static import tango.core.Thread;
static import tango.stdc.stringz;
%}

%pragma(d) imdmodulecode=%{
private class alaqilExceptionHelper {
  static this() {
    alaqilRegisterExceptionCallbacks$module(
      &setException,
      &setIllegalArgumentException,
      &setIllegalElementException,
      &setIOException,
      &setNoSuchElementException);
  }

  static void setException(char* message) {
    auto exception = new object.Exception(tango.stdc.stringz.fromStringz(message).dup);
    alaqilPendingException.set(exception);
  }

  static void setIllegalArgumentException(char* message) {
    auto exception = new tango.core.Exception.IllegalArgumentException(tango.stdc.stringz.fromStringz(message).dup);
    alaqilPendingException.set(exception);
  }

  static void setIllegalElementException(char* message) {
    auto exception = new tango.core.Exception.IllegalElementException(tango.stdc.stringz.fromStringz(message).dup);
    alaqilPendingException.set(exception);
  }

  static void setIOException(char* message) {
    auto exception = new tango.core.Exception.IOException(tango.stdc.stringz.fromStringz(message).dup);
    alaqilPendingException.set(exception);
  }

  static void setNoSuchElementException(char* message) {
    auto exception = new tango.core.Exception.NoSuchElementException(tango.stdc.stringz.fromStringz(message).dup);
    alaqilPendingException.set(exception);
  }
}

package class alaqilPendingException {
public:
  static this() {
    m_sPendingException = new ThreadLocalData(null);
  }

  static bool isPending() {
    return m_sPendingException.val !is null;
  }

  static void set(object.Exception e) {
    auto pending = m_sPendingException.val;
    if (pending !is null) {
      e.next = pending;
      throw new object.Exception("FATAL: An earlier pending exception from C/C++ " ~
        "code was missed and thus not thrown (" ~ pending.classinfo.name ~ ": " ~
        pending.msg ~ ")!", e);
    }
    m_sPendingException.val = e;
  }

  static object.Exception retrieve() {
    auto e = m_sPendingException.val;
    m_sPendingException.val = null;
    return e;
  }

private:
  // The reference to the pending exception (if any) is stored thread-local.
  alias tango.core.Thread.ThreadLocal!(object.Exception) ThreadLocalData;
  static ThreadLocalData m_sPendingException;
}
alias void function(char* message) alaqilExceptionCallback;
%}
#else
%pragma(d) imdmoduleimports=%{
static import std.conv;
%}

%pragma(d) imdmodulecode=%{
private class alaqilExceptionHelper {
  static this() {
	// The D1/Tango version maps C++ exceptions to multiple exception types.
    alaqilRegisterExceptionCallbacks$module(
      &setException,
      &setException,
      &setException,
      &setException,
      &setException
    );
  }

  static void setException(const char* message) {
    auto exception = new object.Exception(std.conv.to!string(message));
    alaqilPendingException.set(exception);
  }
}

package struct alaqilPendingException {
public:
  static this() {
    m_sPendingException = null;
  }

  static bool isPending() {
    return m_sPendingException !is null;
  }

  static void set(object.Exception e) {
    if (m_sPendingException !is null) {
      e.next = m_sPendingException;
      throw new object.Exception("FATAL: An earlier pending exception from C/C++ code " ~
        "was missed and thus not thrown (" ~ m_sPendingException.classinfo.name ~
        ": " ~ m_sPendingException.msg ~ ")!", e);
    }

    m_sPendingException = e;
  }

  static object.Exception retrieve() {
    auto e = m_sPendingException;
    m_sPendingException = null;
    return e;
  }

private:
  // The reference to the pending exception (if any) is stored thread-local.
  static object.Exception m_sPendingException;
}
alias void function(const char* message) alaqilExceptionCallback;
%}
#endif
// Callback registering function in wrapperloader.swg.
#endif // alaqil_D_NO_EXCEPTION_HELPER


/*
 * String support code.
 */

#if !defined(alaqil_D_NO_STRING_HELPER)
%insert(runtime) %{
// Callback for returning strings to D without leaking memory.
typedef char * (* alaqil_DStringHelperCallback)(const char *);
static alaqil_DStringHelperCallback alaqil_d_string_callback = NULL;

#ifdef __cplusplus
extern "C"
#endif
alaqilEXPORT void alaqilRegisterStringCallback_$module(alaqil_DStringHelperCallback callback) {
  alaqil_d_string_callback = callback;
}
%}

#if (alaqil_D_VERSION == 1)
%pragma(d) imdmoduleimports = "static import tango.stdc.stringz;";

%pragma(d) imdmodulecode = %{
private class alaqilStringHelper {
  static this() {
    alaqilRegisterStringCallback$module(&createString);
  }

  static char* createString(char* cString) {
    // We are effectively dup'ing the string here.
    return tango.stdc.stringz.toStringz(tango.stdc.stringz.fromStringz(cString));
  }
}
alias char* function(char* cString) alaqilStringCallback;
%}
#else
%pragma(d) imdmoduleimports = %{
static import std.conv;
static import std.string;
%}

%pragma(d) imdmodulecode = %{
private class alaqilStringHelper {
  static this() {
    alaqilRegisterStringCallback$module(&createString);
  }

  static const(char)* createString(const(char*) cString) {
    // We are effectively dup'ing the string here.
    // TODO: Is this also correct for D2/Phobos?
    return std.string.toStringz(std.conv.to!string(cString));
  }
}
alias const(char)* function(const(char*) cString) alaqilStringCallback;
%}
#endif
// Callback registering function in wrapperloader.swg.
#endif // alaqil_D_NO_STRING_HELPER


/*
 * Function pointer support code.
 */
#if (alaqil_D_VERSION == 1)
%pragma(d) imdmodulecode = %{
template alaqilExternC(T) {
  static if (is(typeof(*(T.init)) R == return)) {
    static if (is(typeof(*(T.init)) P == function)) {
      alias extern(C) R function(P) alaqilExternC;
    }
  }
}
%}
#else
%pragma(d) imdmodulecode = %{
template alaqilExternC(T) if (is(typeof(*(T.init)) P == function)) {
  static if (is(typeof(*(T.init)) R == return)) {
    static if (is(typeof(*(T.init)) P == function)) {
      alias extern(C) R function(P) alaqilExternC;
    }
  }
}
%}
#endif
