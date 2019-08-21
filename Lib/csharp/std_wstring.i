/* -----------------------------------------------------------------------------
 * std_wstring.i
 *
 * Typemaps for std::wstring and const std::wstring&
 * These are mapped to a C# String and are passed around by value.
 *
 * To use non-const std::wstring references use the following %apply.  Note 
 * that they are passed by value.
 * %apply const std::wstring & {std::wstring &};
 * ----------------------------------------------------------------------------- */

%include <wchar.i>

%{
#include <string>
%}

namespace std {

%naturalvar wstring;

class wstring;

// wstring
%typemap(ctype, out="void *") wstring "wchar_t *"
%typemap(imtype, inattributes="[global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPWStr)]") wstring "string"
%typemap(cstype) wstring "string"
%typemap(csdirectorin) wstring "$iminput"
%typemap(csdirectorout) wstring "$cscall"

%typemap(in, canthrow=1) wstring 
%{ if (!$input) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "null wstring", 0);
    return $null;
   }
   $1.assign($input); %}
%typemap(out) wstring %{ $result = alaqil_csharp_wstring_callback($1.c_str()); %}

%typemap(directorout, canthrow=1) wstring 
%{ if (!$input) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "null wstring", 0);
    return $null;
   }
   $result.assign($input); %}

%typemap(directorin) wstring %{ $input = alaqil_csharp_wstring_callback($1.c_str()); %}

%typemap(csin) wstring "$csinput"
%typemap(csout, excode=alaqilEXCODE) wstring {
    string ret = $imcall;$excode
    return ret;
  }

%typemap(typecheck) wstring = wchar_t *;

%typemap(throws, canthrow=1) wstring
%{ std::string message($1.begin(), $1.end());
   alaqil_CSharpSetPendingException(alaqil_CSharpApplicationException, message.c_str());
   return $null; %}

// const wstring &
%typemap(ctype, out="void *") const wstring & "wchar_t *"
%typemap(imtype, inattributes="[global::System.Runtime.InteropServices.MarshalAs(global::System.Runtime.InteropServices.UnmanagedType.LPWStr)]") const wstring & "string"  
%typemap(cstype) const wstring & "string"

%typemap(csdirectorin) const wstring & "$iminput"
%typemap(csdirectorout) const wstring & "$cscall"

%typemap(in, canthrow=1) const wstring &
%{ if (!$input) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "null wstring", 0);
    return $null;
   }
   std::wstring $1_str($input);
   $1 = &$1_str; %}
%typemap(out) const wstring & %{ $result = alaqil_csharp_wstring_callback($1->c_str()); %}

%typemap(csin) const wstring & "$csinput"
%typemap(csout, excode=alaqilEXCODE) const wstring & {
    string ret = $imcall;$excode
    return ret;
  }

%typemap(directorout, canthrow=1, warning=alaqilWARN_TYPEMAP_THREAD_UNSAFE_MSG) const wstring &
%{ if (!$input) {
    alaqil_CSharpSetPendingExceptionArgument(alaqil_CSharpArgumentNullException, "null wstring", 0);
    return $null;
   }
   /* possible thread/reentrant code problem */
   static std::wstring $1_str;
   $1_str = $input;
   $result = &$1_str; %}

%typemap(directorin) const wstring & %{ $input = alaqil_csharp_wstring_callback($1.c_str()); %}

%typemap(csvarin, excode=alaqilEXCODE2) const wstring & %{
    set {
      $imcall;$excode
    } %}
%typemap(csvarout, excode=alaqilEXCODE2) const wstring & %{
    get {
      string ret = $imcall;$excode
      return ret;
    } %}

%typemap(typecheck) const wstring & = wchar_t *;

%typemap(throws, canthrow=1) const wstring &
%{ std::string message($1.begin(), $1.end());
   alaqil_CSharpSetPendingException(alaqil_CSharpApplicationException, message.c_str());
   return $null; %}

}

