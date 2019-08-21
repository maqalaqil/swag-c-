/* -----------------------------------------------------------------------------
 * denums.swg
 *
 * Typemaps for enumerations.
 * ----------------------------------------------------------------------------- */


/*
 * Typemaps for enumeration types.
 */

%typemap(ctype) enum alaqilTYPE "int"
%typemap(imtype) enum alaqilTYPE "int"
%typemap(dtype, cprimitive="1") enum alaqilTYPE "$dclassname"

%typecheck(alaqil_TYPECHECK_POINTER) enum alaqilTYPE ""

%typemap(in) enum alaqilTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum alaqilTYPE %{ $result = (int)$1; %}

%typemap(directorout) enum alaqilTYPE %{ $result = ($1_ltype)$input; %}
%typemap(directorin) enum alaqilTYPE "$input = (int)$1;"
%typemap(ddirectorin) enum alaqilTYPE "cast($dclassname)$winput"
%typemap(ddirectorout) enum alaqilTYPE "cast(int)$dcall"

%typemap(din) enum alaqilTYPE "cast(int)$dinput"
%typemap(dout, excode=alaqilEXCODE) enum alaqilTYPE {
  $dclassname ret = cast($dclassname)$imcall;$excode
  return ret;
}


/*
 * Typemaps for (const) references to enumeration types.
 */

%typemap(ctype) const enum alaqilTYPE & "int"
%typemap(imtype) const enum alaqilTYPE & "int"
%typemap(dtype) const enum alaqilTYPE & "$*dclassname"

%typecheck(alaqil_TYPECHECK_POINTER) const enum alaqilTYPE & ""

%typemap(in) const enum alaqilTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input;
   $1 = &temp; %}
%typemap(out) const enum alaqilTYPE & %{ $result = (int)*$1; %}

%typemap(directorin) const enum alaqilTYPE & "$input = (int)$1;"
%typemap(directorout,warning=alaqilWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum alaqilTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input;
   $result = &temp; %}

%typemap(ddirectorin) const enum alaqilTYPE & "cast($*dclassname)$winput"
%typemap(ddirectorout) const enum alaqilTYPE & "cast(int)$dcall"

%typemap(din) const enum alaqilTYPE & "cast(int)$dinput"
%typemap(dout, excode=alaqilEXCODE) const enum alaqilTYPE & {
  $*dclassname ret = cast($*dclassname)$imcall;$excode
  return ret;
}
