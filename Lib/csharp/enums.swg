/* -----------------------------------------------------------------------------
 * enums.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by proper C# enums.
 * Note that the PINVOKE layer handles the enum as an int.
 * ----------------------------------------------------------------------------- */

// const enum alaqilTYPE & typemaps
%typemap(ctype) const enum alaqilTYPE & "int"
%typemap(imtype) const enum alaqilTYPE & "int"
%typemap(cstype) const enum alaqilTYPE & "$*csclassname"

%typemap(in) const enum alaqilTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}
%typemap(out) const enum alaqilTYPE & %{ $result = (int)*$1; %}

%typemap(directorout,warning=alaqilWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum alaqilTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input; 
   $result = &temp; %}
%typemap(directorin) const enum alaqilTYPE & "$input = (int)$1;"
%typemap(csdirectorin) const enum alaqilTYPE & "($*csclassname)$iminput"
%typemap(csdirectorout) const enum alaqilTYPE & "(int)$cscall"

%typecheck(alaqil_TYPECHECK_POINTER) const enum alaqilTYPE & ""

%typemap(throws, canthrow=1) const enum alaqilTYPE &
%{ (void)$1;
   alaqil_CSharpSetPendingException(alaqil_CSharpApplicationException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(csin) const enum alaqilTYPE & "(int)$csinput"
%typemap(csout, excode=alaqilEXCODE) const enum alaqilTYPE & {
    $*csclassname ret = ($*csclassname)$imcall;$excode
    return ret;
  }

%typemap(csvarout, excode=alaqilEXCODE2) const enum alaqilTYPE & %{
    get {
      $*csclassname ret = ($*csclassname)$imcall;$excode
      return ret;
    } %}


// enum alaqilTYPE typemaps
%typemap(ctype) enum alaqilTYPE "int"
%typemap(imtype) enum alaqilTYPE "int"
%typemap(cstype) enum alaqilTYPE "$csclassname"

%typemap(in) enum alaqilTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum alaqilTYPE %{ $result = (int)$1; %}

%typemap(directorout) enum alaqilTYPE  %{ $result = ($1_ltype)$input; %}
%typemap(directorin) enum alaqilTYPE "$input = (int)$1;"
%typemap(csdirectorin) enum alaqilTYPE "($csclassname)$iminput"
%typemap(csdirectorout) enum alaqilTYPE "(int)$cscall"

%typecheck(alaqil_TYPECHECK_POINTER) enum alaqilTYPE ""

%typemap(throws, canthrow=1) enum alaqilTYPE
%{ (void)$1;
   alaqil_CSharpSetPendingException(alaqil_CSharpApplicationException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(csin) enum alaqilTYPE "(int)$csinput"
%typemap(csout, excode=alaqilEXCODE) enum alaqilTYPE {
    $csclassname ret = ($csclassname)$imcall;$excode
    return ret;
  }

%typemap(csvarout, excode=alaqilEXCODE2) enum alaqilTYPE %{
    get {
      $csclassname ret = ($csclassname)$imcall;$excode
      return ret;
    } %}

%typemap(csbase)           enum alaqilTYPE ""
%typemap(csclassmodifiers) enum alaqilTYPE "public enum"
%typemap(cscode)           enum alaqilTYPE ""
%typemap(csimports)        enum alaqilTYPE ""
%typemap(csinterfaces)     enum alaqilTYPE ""

%typemap(csbody) enum alaqilTYPE ""

%csenum(proper);

