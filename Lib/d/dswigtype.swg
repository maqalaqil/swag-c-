/* -----------------------------------------------------------------------------
 * dalaqiltype.swg
 *
 * Typemaps for non-primitive types (C/C++ classes and structs).
 * ----------------------------------------------------------------------------- */

%typemap(ctype) alaqilTYPE "void *"
%typemap(imtype) alaqilTYPE "void*"
%typemap(dtype) alaqilTYPE "$&dclassname"

%typemap(ctype) alaqilTYPE [] "void *"
%typemap(imtype) alaqilTYPE [] "void*"
%typemap(dtype) alaqilTYPE [] "$dclassname"

%typemap(ctype) alaqilTYPE * "void *"
%typemap(imtype) alaqilTYPE * "void*"
%typemap(dtype, nativepointer="$dtype") alaqilTYPE * "$dclassname"

%typemap(ctype) alaqilTYPE & "void *"
%typemap(imtype) alaqilTYPE & "void*"
%typemap(dtype, nativepointer="$dtype") alaqilTYPE & "$dclassname"

%typemap(ctype) alaqilTYPE *const& "void *"
%typemap(imtype) alaqilTYPE *const& "void*"
%typemap(dtype) alaqilTYPE *const& "$*dclassname"

%typecheck(alaqil_TYPECHECK_POINTER)
    alaqilTYPE,
    alaqilTYPE *,
    alaqilTYPE &,
    alaqilTYPE [],
    alaqilTYPE *const&
  ""


/*
 * By-value conversion typemaps (parameter is converted to a pointer).
 */

%typemap(in, canthrow=1) alaqilTYPE ($&1_type argp)
%{ argp = ($&1_ltype)$input;
   if (!argp) {
     alaqil_DSetPendingException(alaqil_DIllegalArgumentException, "Attempt to dereference null $1_type");
     return $null;
   }
   $1 = *argp; %}

%typemap(out) alaqilTYPE
#ifdef __cplusplus
%{ $result = new $1_ltype((const $1_ltype &)$1); %}
#else
{
  $&1_ltype $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  $result = $1ptr;
}
#endif

%typemap(directorin) alaqilTYPE
  "$input = (void *)new $1_ltype((const $1_ltype &)$1);"
%typemap(directorout) alaqilTYPE
%{ if (!$input) {
     alaqil_DSetPendingException(alaqil_DIllegalArgumentException, "Unexpected null return for type $1_type");
     return $null;
   }
   $result = *($&1_ltype)$input; %}

%typemap(ddirectorin) alaqilTYPE "new $&dclassname($winput, true)"
%typemap(ddirectorout) alaqilTYPE "$&dclassname.alaqilGetCPtr($dcall)"

%typemap(din) alaqilTYPE "$&dclassname.alaqilGetCPtr($dinput)"
%typemap(dout, excode=alaqilEXCODE) alaqilTYPE {
  $&dclassname ret = new $&dclassname($imcall, true);$excode
  return ret;
}


/*
 * Pointer conversion typemaps.
 */

%typemap(in) alaqilTYPE * "$1 = ($1_ltype)$input;"
%typemap(out) alaqilTYPE * "$result = (void *)$1;"

%typemap(directorin) alaqilTYPE *
  "$input = (void *) $1;"
%typemap(directorout, warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) alaqilTYPE *
  "$result = ($1_ltype)$input;"

%typemap(ddirectorin,
  nativepointer="cast($dtype)$winput"
) alaqilTYPE * "($winput is null) ? null : new $dclassname($winput, false)"

%typemap(ddirectorout,
  nativepointer="cast(void*)$dcall"
) alaqilTYPE * "$dclassname.alaqilGetCPtr($dcall)"

%typemap(din,
  nativepointer="cast(void*)$dinput"
) alaqilTYPE * "$dclassname.alaqilGetCPtr($dinput)"

%typemap(dout, excode=alaqilEXCODE,
  nativepointer="{\n  auto ret = cast($dtype)$imcall;$excode\n  return ret;\n}"
) alaqilTYPE * {
  void* cPtr = $imcall;
  $dclassname ret = (cPtr is null) ? null : new $dclassname(cPtr, $owner);$excode
  return ret;
}

// Use the same typemaps for const pointers.
%apply alaqilTYPE * { alaqilTYPE *const }


/*
 * Reference conversion typemaps.
 */

%typemap(in, canthrow=1) alaqilTYPE & %{ $1 = ($1_ltype)$input;
  if (!$1) {
    alaqil_DSetPendingException(alaqil_DIllegalArgumentException, "$1_type type is null");
    return $null;
  } %}
%typemap(out) alaqilTYPE & "$result = (void *)$1;"

%typemap(directorin) alaqilTYPE &
  "$input = ($1_ltype) &$1;"
%typemap(directorout, warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) alaqilTYPE &
%{ if (!$input) {
     alaqil_DSetPendingException(alaqil_DIllegalArgumentException, "Unexpected null return for type $1_type");
     return $null;
   }
   $result = ($1_ltype)$input; %}

%typemap(ddirectorin,
  nativepointer="cast($dtype)$winput"
) alaqilTYPE & "new $dclassname($winput, false)"
%typemap(ddirectorout,
  nativepointer="cast(void*)$dcall"
) alaqilTYPE & "$dclassname.alaqilGetCPtr($dcall)"

%typemap(din,
  nativepointer="cast(void*)$dinput"
) alaqilTYPE & "$dclassname.alaqilGetCPtr($dinput)"
%typemap(dout, excode=alaqilEXCODE,
  nativepointer="{\n  auto ret = cast($dtype)$imcall;$excode\n  return ret;\n}") alaqilTYPE & {
  $dclassname ret = new $dclassname($imcall, $owner);$excode
  return ret;
}


/*
 * Array conversion typemaps.
 */

%typemap(in) alaqilTYPE [] %{ $1 = ($1_ltype)$input; %}
%typemap(out) alaqilTYPE [] %{ $result = $1; %}

%typemap(din) alaqilTYPE [] "$dclassname.alaqilGetCPtr($dinput)"
%typemap(dout, excode=alaqilEXCODE) alaqilTYPE [] {
  void* cPtr = $imcall;
  $dclassname ret = (cPtr is null) ? null : new $dclassname(cPtr, $owner);$excode
  return ret;
}

// Treat references to arrays like references to a single element.
%apply alaqilTYPE & { alaqilTYPE ((&)[ANY]) }


/*
 * Pointer reference conversion typemaps.
 */

%typemap(in) alaqilTYPE *const& ($*1_ltype temp = 0)
%{ temp = ($*1_ltype)$input;
   $1 = ($1_ltype)&temp; %}
%typemap(out) alaqilTYPE *const&
%{ $result = (void *)*$1; %}

%typemap(din) alaqilTYPE *const& "$*dclassname.alaqilGetCPtr($dinput)"
%typemap(dout, excode=alaqilEXCODE) alaqilTYPE *const& {
  void* cPtr = $imcall;
  $*dclassname ret = (cPtr is null) ? null : new $*dclassname(cPtr, $owner);$excode
  return ret;
}
%typemap(directorin) alaqilTYPE *const&
  "$input = (void *) $1;"
%typemap(directorout, warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) alaqilTYPE *const&
%{ static $*1_ltype alaqil_temp;
   alaqil_temp = ($*1_ltype)$input;
   $result = &alaqil_temp; %}
%typemap(ddirectorin,
  nativepointer="cast($dtype)$winput"
) alaqilTYPE *const& "($winput is null) ? null : new $*dclassname($winput, false)"
%typemap(ddirectorout,
  nativepointer="cast(void*)$dcall"
) alaqilTYPE *const& "$*dclassname.alaqilGetCPtr($dcall)"

