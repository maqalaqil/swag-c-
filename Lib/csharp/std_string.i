/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * Typemaps for std::string and const std::string&
 * These are mapped to a C# String and are passed around by value.
 *
 * To use non-const std::string references use the following %apply.  Note 
 * that they are passed by value.
 * %apply const std::string & {std::string &};
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {

%naturalvar string;

class string;

// string
%typemap(ctype) string "char *"
%typemap(imtype) string "string"
%typemap(cstype) string "string"

%typemap(csdirectorin) string "$iminput"
%typemap(csdirectorout) string "$cscall"

%typemap(in, canthrow=1) string 
%{ if (!$input) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "null string", 0);
    return $null;
   }
   $1.assign($input); %}
%typemap(out) string %{ $result = alaqil_csharp_string_callback($1.c_str()); %}

%typemap(directorout, canthrow=1) string 
%{ if (!$input) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "null string", 0);
    return $null;
   }
   $result.assign($input); %}

%typemap(directorin) string %{ $input = alaqil_csharp_string_callback($1.c_str()); %}

%typemap(csin) string "$csinput"
%typemap(csout, excode=alaqilEXCODE) string {
    string ret = $imcall;$excode
    return ret;
  }

%typemap(typecheck) string = char *;

%typemap(throws, canthrow=1) string
%{ alaqil_CSharpSetPendingException(alaqil_CSharpApplicationException, $1.c_str());
   return $null; %}

// const string &
%typemap(ctype) const string & "char *"
%typemap(imtype) const string & "string"
%typemap(cstype) const string & "string"

%typemap(csdirectorin) const string & "$iminput"
%typemap(csdirectorout) const string & "$cscall"

%typemap(in, canthrow=1) const string &
%{ if (!$input) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "null string", 0);
    return $null;
   }
   $*1_ltype $1_str($input);
   $1 = &$1_str; %}
%typemap(out) const string & %{ $result = alaqil_csharp_string_callback($1->c_str()); %}

%typemap(csin) const string & "$csinput"
%typemap(csout, excode=alaqilEXCODE) const string & {
    string ret = $imcall;$excode
    return ret;
  }

%typemap(directorout, canthrow=1, warning=alaqilWARN_TYPEMAP_THREAD_UNSAFE_MSG) const string &
%{ if (!$input) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "null string", 0);
    return $null;
   }
   /* possible thread/reentrant code problem */
   static $*1_ltype $1_str;
   $1_str = $input;
   $result = &$1_str; %}

%typemap(directorin) const string & %{ $input = alaqil_csharp_string_callback($1.c_str()); %}

%typemap(csvarin, excode=alaqilEXCODE2) const string & %{
    set {
      $imcall;$excode
    } %}
%typemap(csvarout, excode=alaqilEXCODE2) const string & %{
    get {
      string ret = $imcall;$excode
      return ret;
    } %}

%typemap(typecheck) const string & = char *;

%typemap(throws, canthrow=1) const string &
%{ alaqil_CSharpSetPendingException(alaqil_CSharpApplicationException, $1.c_str());
   return $null; %}

}

