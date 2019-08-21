/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * Typemaps for std::string and const std::string&
 * These are mapped to a D char[] and are passed around by value.
 *
 * To use non-const std::string references, use the following %apply. Note
 * that they are passed by value.
 * %apply const std::string & {std::string &};
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {

%naturalvar string;

class string;

%define alaqilD_STD_STRING_TYPEMAPS(DW_STRING_TYPE, DP_STRING_TYPE, FROM_STRINGZ, TO_STRINGZ)
// string
%typemap(ctype) string, const string & "char *"
%typemap(imtype) string, const string & #DW_STRING_TYPE
%typemap(dtype) string, const string & #DP_STRING_TYPE

%typemap(in, canthrow=1) string, const string &
%{ if (!$input) {
    alaqil_DSetPendingException(alaqil_DIllegalArgumentException, "null string");
    return $null;
  }
  $1.assign($input); %}
%typemap(in, canthrow=1) const string &
%{ if (!$input) {
    alaqil_DSetPendingException(alaqil_DIllegalArgumentException, "null string");
    return $null;
   }
   $*1_ltype $1_str($input);
   $1 = &$1_str; %}

%typemap(out) string %{ $result = alaqil_d_string_callback($1.c_str()); %}
%typemap(out) const string & %{ $result = alaqil_d_string_callback($1->c_str()); %}

%typemap(din) string, const string & "($dinput ? TO_STRINGZ($dinput) : null)"
%typemap(dout, excode=alaqilEXCODE) string, const string & {
  DP_STRING_TYPE ret = FROM_STRINGZ($imcall);$excode
  return ret;
}

%typemap(directorin) string, const string & %{ $input = alaqil_d_string_callback($1.c_str()); %}

%typemap(directorout, canthrow=1) string
%{ if (!$input) {
    alaqil_DSetPendingException(alaqil_DIllegalArgumentException, "null string");
    return $null;
  }
  $result.assign($input); %}

%typemap(directorout, canthrow=1, warning=alaqilWARN_TYPEMAP_THREAD_UNSAFE_MSG) const string &
%{ if (!$input) {
    alaqil_DSetPendingException(alaqil_DIllegalArgumentException, "null string");
    return $null;
  }
  /* possible thread/reentrant code problem */
  static $*1_ltype $1_str;
  $1_str = $input;
  $result = &$1_str; %}

%typemap(ddirectorin) string, const string & "FROM_STRINGZ($winput)"
%typemap(ddirectorout) string, const string & "TO_STRINGZ($dcall)"

%typemap(throws, canthrow=1) string, const string &
%{ alaqil_DSetPendingException(alaqil_DException, $1.c_str());
  return $null; %}

%typemap(typecheck) string, const string & = char *;
%enddef

// We need to have the \0-terminated string conversion functions available in
// the D proxy modules.
#if (alaqil_D_VERSION == 1)
// Could be easily extended to support Phobos as well.
alaqilD_STD_STRING_TYPEMAPS(char*, char[], tango.stdc.stringz.fromStringz, tango.stdc.stringz.toStringz)

%pragma(d) globalproxyimports = "static import tango.stdc.stringz;";
#else
alaqilD_STD_STRING_TYPEMAPS(const(char)*, string, std.conv.to!string, std.string.toStringz)

%pragma(d) globalproxyimports = %{
static import std.conv;
static import std.string;
%}
#endif

#undef alaqilD_STD_STRING_TYPEMAPS

} // namespace std
