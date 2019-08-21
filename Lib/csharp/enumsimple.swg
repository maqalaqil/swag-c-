/* -----------------------------------------------------------------------------
 * enumsimple.swg
 *
 * This file provides backwards compatible enum wrapping. alaqil versions 1.3.21
 * and earlier wrapped global enums with constant integers in the module
 * class. Enums declared within a C++ class were wrapped by constant integers
 * in the C# proxy class.
 * ----------------------------------------------------------------------------- */

// const enum alaqilTYPE & typemaps
%typemap(ctype) const enum alaqilTYPE & "int"
%typemap(imtype) const enum alaqilTYPE & "int"
%typemap(cstype) const enum alaqilTYPE & "int"

%typemap(in) const enum alaqilTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}
%typemap(out) const enum alaqilTYPE & %{ $result = (int)*$1; %}

%typemap(directorout,warning=alaqilWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum alaqilTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input; 
   $result = &temp; %}
%typemap(directorin) const enum alaqilTYPE & "$input = (int)$1;"
%typemap(csdirectorin) const enum alaqilTYPE & "$iminput"
%typemap(csdirectorout) const enum alaqilTYPE & "$cscall"

%typecheck(alaqil_TYPECHECK_INT32) const enum alaqilTYPE & ""

%typemap(throws, canthrow=1) const enum alaqilTYPE &
%{ (void)$1;
   alaqil_CSharpSetPendingException(alaqil_CSharpApplicationException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(csin) const enum alaqilTYPE & "$csinput"
%typemap(csout, excode=alaqilEXCODE) const enum alaqilTYPE & {
    int ret = $imcall;$excode
    return ret;
  }

%typemap(csvarout, excode=alaqilEXCODE2) const enum alaqilTYPE & %{
    get {
      int ret = $imcall;$excode
      return ret;
    } %}


// enum alaqilTYPE typemaps
%typemap(ctype) enum alaqilTYPE "int"
%typemap(imtype) enum alaqilTYPE "int"
%typemap(cstype) enum alaqilTYPE "int"

%typemap(in) enum alaqilTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum alaqilTYPE %{ $result = (int)$1; %}

%typemap(directorout) enum alaqilTYPE  %{ $result = ($1_ltype)$input; %}
%typemap(directorin) enum alaqilTYPE "$input = (int)$1;"
%typemap(csdirectorin) enum alaqilTYPE "$iminput"
%typemap(csdirectorout) enum alaqilTYPE "$cscall"

%typecheck(alaqil_TYPECHECK_INT32) enum alaqilTYPE ""

%typemap(throws, canthrow=1) enum alaqilTYPE
%{ (void)$1;
   alaqil_CSharpSetPendingException(alaqil_CSharpApplicationException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(csin) enum alaqilTYPE "$csinput"
%typemap(csout, excode=alaqilEXCODE) enum alaqilTYPE {
    int ret = $imcall;$excode
    return ret;
  }

%typemap(csvarout, excode=alaqilEXCODE2) enum alaqilTYPE %{
    get {
      int ret = $imcall;$excode
      return ret;
    } %}

%typemap(csbase)           enum alaqilTYPE ""
%typemap(csclassmodifiers) enum alaqilTYPE ""
%typemap(cscode)           enum alaqilTYPE ""
%typemap(csimports)        enum alaqilTYPE ""
%typemap(csinterfaces)     enum alaqilTYPE ""

%typemap(csbody) enum alaqilTYPE ""

%csenum(simple);

