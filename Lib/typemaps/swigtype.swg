/* -----------------------------------------------------------------------------
 * --- Input arguments --- 
 * ----------------------------------------------------------------------------- */
/* Pointers and arrays */
%typemap(in, noblock=1) alaqilTYPE *(void  *argp = 0, int res = 0) {
  res = alaqil_ConvertPtr($input, &argp,$descriptor, $disown | %convertptr_flags);
  if (!alaqil_IsOK(res)) { 
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  $1 = %reinterpret_cast(argp, $ltype);
}
%typemap(freearg) alaqilTYPE * "";

%typemap(in, noblock=1) alaqilTYPE [] (void *argp = 0, int res = 0) {
  res = alaqil_ConvertPtr($input, &argp,$descriptor, $disown | %convertptr_flags);
  if (!alaqil_IsOK(res)) { 
    %argument_fail(res, "$type", $symname, $argnum); 
  } 
  $1 = %reinterpret_cast(argp, $ltype);
}
%typemap(freearg) alaqilTYPE [] "";


%typemap(in, noblock=1) alaqilTYPE *const&  (void *argp = 0, int res = 0, $*1_ltype temp) {
  res = alaqil_ConvertPtr($input, &argp, $*descriptor, $disown | %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$*ltype", $symname, $argnum); 
  }
  temp = %reinterpret_cast(argp, $*ltype);
  $1 = %reinterpret_cast(&temp, $1_ltype);
}
%typemap(freearg) alaqilTYPE *const& "";


/* Reference */
%typemap(in, noblock=1) alaqilTYPE & (void *argp = 0, int res = 0) {
  res = alaqil_ConvertPtr($input, &argp, $descriptor, %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (!argp) { %argument_nullref("$type", $symname, $argnum); }
  $1 = %reinterpret_cast(argp, $ltype);
}
%typemap(freearg) alaqilTYPE & "";

#if defined(__cplusplus) && defined(%implicitconv_flag)
%typemap(in,noblock=1,implicitconv=1) const alaqilTYPE & (void *argp = 0, int res = 0) {
  res = alaqil_ConvertPtr($input, &argp, $descriptor, %convertptr_flags | %implicitconv_flag);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (!argp) { %argument_nullref("$type", $symname, $argnum); }
  $1 = %reinterpret_cast(argp, $ltype);
}
%typemap(freearg,noblock=1,match="in",implicitconv=1) const alaqilTYPE &
{
  if (alaqil_IsNewObj(res$argnum)) %delete($1);
}
#else
%typemap(in,noblock=1) const alaqilTYPE & (void *argp, int res = 0) {
  res = alaqil_ConvertPtr($input, &argp, $descriptor, %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (!argp) { %argument_nullref("$type", $symname, $argnum); }
  $1 = %reinterpret_cast(argp, $ltype);
}
#endif

/* Rvalue reference */
%typemap(in, noblock=1) alaqilTYPE && (void *argp = 0, int res = 0) {
  res = alaqil_ConvertPtr($input, &argp, $descriptor, %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (!argp) { %argument_nullref("$type", $symname, $argnum); }
  $1 = %reinterpret_cast(argp, $ltype);
}
%typemap(freearg) alaqilTYPE && "";

#if defined(__cplusplus) && defined(%implicitconv_flag)
%typemap(in,noblock=1,implicitconv=1) const alaqilTYPE && (void *argp = 0, int res = 0) {
  res = alaqil_ConvertPtr($input, &argp, $descriptor, %convertptr_flags | %implicitconv_flag);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (!argp) { %argument_nullref("$type", $symname, $argnum); }
  $1 = %reinterpret_cast(argp, $ltype);
}
%typemap(freearg,noblock=1,match="in",implicitconv=1) const alaqilTYPE &&
{
  if (alaqil_IsNewObj(res$argnum)) %delete($1);
}
#else
%typemap(in,noblock=1) const alaqilTYPE && (void *argp, int res = 0) {
  res = alaqil_ConvertPtr($input, &argp, $descriptor, %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }
  if (!argp) { %argument_nullref("$type", $symname, $argnum); }
  $1 = %reinterpret_cast(argp, $ltype);
}
#endif

/* By value */
#if defined(__cplusplus) && defined(%implicitconv_flag)
%typemap(in,implicitconv=1) alaqilTYPE (void *argp, int res = 0) {
  res = alaqil_ConvertPtr($input, &argp, $&descriptor, %convertptr_flags | %implicitconv_flag);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }  
  if (!argp) { 
    %argument_nullref("$type", $symname, $argnum);
  } else {
    $&ltype temp = %reinterpret_cast(argp, $&ltype);
    $1 = *temp;
    if (alaqil_IsNewObj(res)) %delete(temp);
  }
}
#else
%typemap(in) alaqilTYPE (void *argp, int res = 0) {
  res = alaqil_ConvertPtr($input, &argp, $&descriptor, %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res, "$type", $symname, $argnum); 
  }  
  if (!argp) { 
    %argument_nullref("$type", $symname, $argnum);
  } else {
    $1 = *(%reinterpret_cast(argp, $&ltype));
  }
}
#endif


/* -----------------------------------------------------------------------------
 * --- Output arguments --- 
 * ----------------------------------------------------------------------------- */

/* Pointers, references */
%typemap(out,noblock=1) alaqilTYPE *, alaqilTYPE &, alaqilTYPE &&, alaqilTYPE[] {
  %set_output(alaqil_NewPointerObj(%as_voidptr($1), $descriptor, $owner | %newpointer_flags));
}

%typemap(out, noblock=1) alaqilTYPE *const& {
  %set_output(alaqil_NewPointerObj(%as_voidptr(*$1), $*descriptor, $owner | %newpointer_flags));
}

/* Return by value */
%typemap(out, noblock=1) alaqilTYPE {
  %set_output(alaqil_NewPointerObj(%new_copy($1, $ltype), $&descriptor, alaqil_POINTER_OWN | %newpointer_flags));
}

/* -----------------------------------------------------------------------------
 * --- Variable input --- 
 * ----------------------------------------------------------------------------- */

/* memberin/globalin/varin, for fix arrays. */

%typemap(memberin) alaqilTYPE [ANY] {
  if ($input) {
    size_t ii = 0;
    for (; ii < (size_t)$1_dim0; ++ii) *($1_basetype *)&$1[ii] = *(($1_basetype *)$input + ii);
  } else {
    %variable_nullref("$type","$name");
  }
}

%typemap(globalin) alaqilTYPE [ANY] {
  if ($input) {
    size_t ii = 0;
    for (; ii < (size_t)$1_dim0; ++ii) *($1_basetype *)&$1[ii] = *(($1_basetype *)$input + ii);
  } else {
    %variable_nullref("$type","$name");
  }
}

%typemap(varin) alaqilTYPE [ANY] {
  $basetype *inp = 0;
  int res = alaqil_ConvertPtr($input, %as_voidptrptr(&inp), $descriptor, %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  } else if (inp) {
    size_t ii = 0;
    for (; ii < (size_t)$1_dim0; ++ii) *($1_basetype *)&$1[ii] = *(($1_basetype *)inp + ii);
  } else {
    %variable_nullref("$type", "$name");
  }
}


/* memberin/globalin/varin, for fix double arrays. */

%typemap(memberin) alaqilTYPE [ANY][ANY] {
  if ($input) {
    size_t ii = 0;
    for (; ii < (size_t)$1_dim0; ++ii) {
      if ($input[ii]) {
	size_t jj = 0;
	for (; jj < (size_t)$1_dim1; ++jj) $1[ii][jj] = $input[ii][jj];
      } else {
	%variable_nullref("$type","$name");
      }
    }
  } else {
    %variable_nullref("$type","$name");
  }
}

%typemap(globalin) alaqilTYPE [ANY][ANY] {
  if ($input) {
    size_t ii = 0;
    for (; ii < (size_t)$1_dim0; ++ii) {
      if ($input[ii]) {
	size_t jj = 0;
	for (; jj < (size_t)$1_dim1; ++jj) $1[ii][jj] = $input[ii][jj];
      } else {
	%variable_nullref("$type","$name");
      }
    }
  } else {
    %variable_nullref("$type","$name");
  }
}

%typemap(varin) alaqilTYPE [ANY][ANY] {
  $basetype (*inp)[$1_dim1] = 0;
  int res = alaqil_ConvertPtr($input, %as_voidptrptr(&inp), $descriptor, %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  } else if (inp) {
    size_t ii = 0;
    for (; ii < (size_t)$1_dim0; ++ii) {
      if (inp[ii]) {
	size_t jj = 0;
	for (; jj < (size_t)$1_dim1; ++jj) $1[ii][jj] = inp[ii][jj];
      } else {
	%variable_nullref("$type", "$name");
      }
    }
  } else {
    %variable_nullref("$type", "$name");
  }
}

/* Pointers, references, and variable size arrays */

%typemap(varin,warning=alaqilWARN_TYPEMAP_alaqilTYPELEAK_MSG) alaqilTYPE * {
  void *argp = 0;
  int res = alaqil_ConvertPtr($input, &argp, $descriptor, %convertptr_flags);  
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  $1 = %reinterpret_cast(argp, $ltype);
}

%typemap(varin,noblock=1,warning="462:Unable to set dimensionless array variable") alaqilTYPE []
{
  %variable_fail(alaqil_AttributeError, "$type", "read-only $name");
}

%typemap(varin,warning=alaqilWARN_TYPEMAP_alaqilTYPELEAK_MSG) alaqilTYPE & {
  void *argp = 0;
  int res = alaqil_ConvertPtr($input, &argp, $descriptor, %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  if (!argp) {
    %variable_nullref("$type", "$name");
  }
  $1 = *(%reinterpret_cast(argp, $ltype));
}

%typemap(varin,warning=alaqilWARN_TYPEMAP_alaqilTYPELEAK_MSG) alaqilTYPE && {
  void *argp = 0;
  int res = alaqil_ConvertPtr($input, &argp, $descriptor, %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  if (!argp) {
    %variable_nullref("$type", "$name");
  }
  $1 = *(%reinterpret_cast(argp, $ltype));
}

#if defined(__cplusplus) && defined(%implicitconv_flag)
%typemap(varin,implicitconv=1) alaqilTYPE {
  void *argp = 0;
  int res = alaqil_ConvertPtr($input, &argp, $&descriptor, %convertptr_flags | %implicitconv_flag);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  if (!argp) {
    %variable_nullref("$type", "$name");
  } else {
    $&type temp;
    temp  = %reinterpret_cast(argp, $&type);
    $1 = *temp;
    if (alaqil_IsNewObj(res)) %delete(temp);
  }
}
#else
%typemap(varin) alaqilTYPE {
  void *argp = 0;
  int res = alaqil_ConvertPtr($input, &argp, $&descriptor, %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  if (!argp) {
    %variable_nullref("$type", "$name");
  } else {
    $1 = *(%reinterpret_cast(argp, $&type));
  }
}
#endif

/* -----------------------------------------------------------------------------
 * --- Variable output --- 
 * ----------------------------------------------------------------------------- */

/* Pointers and arrays */
%typemap(varout, noblock=1) alaqilTYPE * {
  %set_varoutput(alaqil_NewPointerObj(%as_voidptr($1), $descriptor, %newpointer_flags));
}

%typemap(varout, noblock=1) alaqilTYPE [] {
  %set_varoutput(alaqil_NewPointerObj(%as_voidptr($1), $descriptor, %newpointer_flags));
}

/* References */
%typemap(varout, noblock=1) alaqilTYPE & {
  %set_varoutput(alaqil_NewPointerObj(%as_voidptr(&$1), $descriptor, %newpointer_flags));
}

%typemap(varout, noblock=1) alaqilTYPE && {
  %set_varoutput(alaqil_NewPointerObj(%as_voidptr(&$1), $descriptor, %newpointer_flags));
}

/* Value */
%typemap(varout, noblock=1) alaqilTYPE {
  %set_varoutput(alaqil_NewPointerObj(%as_voidptr(&$1), $&descriptor, %newpointer_flags));
}

/* ------------------------------------------------------------
 * --- Typechecking rules ---
 * ------------------------------------------------------------ */

%typemap(typecheck,precedence=alaqil_TYPECHECK_POINTER,noblock=1) alaqilTYPE * {
  void *vptr = 0;
  int res = alaqil_ConvertPtr($input, &vptr, $descriptor, 0);
  $1 = alaqil_CheckState(res);
}

%typemap(typecheck,precedence=alaqil_TYPECHECK_POINTER,noblock=1) alaqilTYPE *const& {
  void *vptr = 0;
  int res = alaqil_ConvertPtr($input, &vptr, $*descriptor, 0);
  $1 = alaqil_CheckState(res);
}

%typemap(typecheck,precedence=alaqil_TYPECHECK_POINTER,noblock=1) alaqilTYPE & {
  void *vptr = 0;
  int res = alaqil_ConvertPtr($input, &vptr, $descriptor, alaqil_POINTER_NO_NULL);
  $1 = alaqil_CheckState(res);
}

%typemap(typecheck,precedence=alaqil_TYPECHECK_POINTER,noblock=1) alaqilTYPE && {
  void *vptr = 0;
  int res = alaqil_ConvertPtr($input, &vptr, $descriptor, alaqil_POINTER_NO_NULL);
  $1 = alaqil_CheckState(res);
}

#if defined(__cplusplus) && defined(%implicitconv_flag)
%typemap(typecheck,precedence=alaqil_TYPECHECK_POINTER,noblock=1,implicitconv=1) const alaqilTYPE & {
  int res = alaqil_ConvertPtr($input, 0, $descriptor, alaqil_POINTER_NO_NULL | %implicitconv_flag);
  $1 = alaqil_CheckState(res);
}

%typemap(typecheck,precedence=alaqil_TYPECHECK_POINTER,noblock=1,implicitconv=1) const alaqilTYPE && {
  int res = alaqil_ConvertPtr($input, 0, $descriptor, alaqil_POINTER_NO_NULL | %implicitconv_flag);
  $1 = alaqil_CheckState(res);
}

%typemap(typecheck,precedence=alaqil_TYPECHECK_POINTER,noblock=1,implicitconv=1) alaqilTYPE {
  int res = alaqil_ConvertPtr($input, 0, $&descriptor, alaqil_POINTER_NO_NULL | %implicitconv_flag);
  $1 = alaqil_CheckState(res);
}
#else
%typemap(typecheck,precedence=alaqil_TYPECHECK_POINTER,noblock=1) const alaqilTYPE & {
  void *vptr = 0;
  int res = alaqil_ConvertPtr($input, &vptr, $descriptor, alaqil_POINTER_NO_NULL);
  $1 = alaqil_CheckState(res);
}
%typemap(typecheck,precedence=alaqil_TYPECHECK_POINTER,noblock=1) const alaqilTYPE && {
  void *vptr = 0;
  int res = alaqil_ConvertPtr($input, &vptr, $descriptor, alaqil_POINTER_NO_NULL);
  $1 = alaqil_CheckState(res);
}

%typemap(typecheck,precedence=alaqil_TYPECHECK_POINTER,noblock=1) alaqilTYPE {
  void *vptr = 0;
  int res = alaqil_ConvertPtr($input, &vptr, $&descriptor, alaqil_POINTER_NO_NULL);
  $1 = alaqil_CheckState(res);
}
#endif

/* -----------------------------------------------------------------------------
 * --- Director typemaps --- *  
 * ----------------------------------------------------------------------------- */

#if defined(alaqil_DIRECTOR_TYPEMAPS)

/* directorin */

%typemap(directorin,noblock=1) alaqilTYPE {
  $input = alaqil_NewPointerObj(%as_voidptr(new $1_ltype((const $1_ltype &)$1)), $&descriptor, alaqil_POINTER_OWN | %newpointer_flags);
}

%typemap(directorin,noblock=1) alaqilTYPE * {
  $input = alaqil_NewPointerObj(%as_voidptr($1), $descriptor, %newpointer_flags);
}

%typemap(directorin,noblock=1) alaqilTYPE *const& {
  $input = alaqil_NewPointerObj(%as_voidptr($1), $*descriptor, %newpointer_flags);
}

%typemap(directorin,noblock=1) alaqilTYPE & {
  $input = alaqil_NewPointerObj(%as_voidptr(&$1), $descriptor, %newpointer_flags);
}

%typemap(directorin,noblock=1) alaqilTYPE && {
  $input = alaqil_NewPointerObj(%as_voidptr(&$1_name), $descriptor, %newpointer_flags);
}

/* directorout */

#if defined(__cplusplus) && defined(%implicitconv_flag)
%typemap(directorout,noblock=1,implicitconv=1) alaqilTYPE (void * alaqil_argp, int alaqil_res = 0) {
  alaqil_res = alaqil_ConvertPtr($input,&alaqil_argp,$&descriptor, %convertptr_flags | %implicitconv_flag);
  if (!alaqil_IsOK(alaqil_res)) {
    %dirout_fail(alaqil_res,"$type");
  }
  $result = *(%reinterpret_cast(alaqil_argp, $&ltype));
  if (alaqil_IsNewObj(alaqil_res)) %delete(%reinterpret_cast(alaqil_argp, $&ltype));
}
#else
%typemap(directorout,noblock=1) alaqilTYPE (void * alaqil_argp, int alaqil_res = 0) {
  alaqil_res = alaqil_ConvertPtr($input,&alaqil_argp,$&descriptor, %convertptr_flags);
  if (!alaqil_IsOK(alaqil_res)) {
    %dirout_fail(alaqil_res,"$type");
  }
  $result = *(%reinterpret_cast(alaqil_argp, $&ltype));
}
#endif

%typemap(directorout,noblock=1,warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) 
  alaqilTYPE *(void *alaqil_argp, int alaqil_res, alaqil_owntype own) {
  alaqil_res = alaqil_ConvertPtrAndOwn($input, &alaqil_argp, $descriptor, %convertptr_flags | alaqil_POINTER_DISOWN, &own);
  if (!alaqil_IsOK(alaqil_res)) {
    %dirout_fail(alaqil_res,"$type");
  }
  $result = %reinterpret_cast(alaqil_argp, $ltype);
  alaqil_acquire_ownership_obj(%as_voidptr($result), own /* & TODO: alaqil_POINTER_OWN */);
}
%typemap(directorfree,noblock=1,match="directorout") alaqilTYPE * {
  if (director) {
    alaqil_AcquirePtr($result, director->alaqil_release_ownership(%as_voidptr($input)));
  }
}

%typemap(directorout,noblock=1,warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) 
  alaqilTYPE *const&(void *alaqil_argp, int alaqil_res, alaqil_owntype own) {
  alaqil_res = alaqil_ConvertPtrAndOwn($input, &alaqil_argp, $*descriptor, %convertptr_flags | alaqil_POINTER_DISOWN, &own);
  if (!alaqil_IsOK(alaqil_res)) {
    %dirout_fail(alaqil_res,"$type");
  }
  $1_ltype alaqil_temp = new $*1_ltype(($*1_ltype)alaqil_argp);
  alaqil_acquire_ownership(alaqil_temp);
  $result = alaqil_temp;
}
%typemap(directorfree,noblock=1,match="directorout") alaqilTYPE *const& {
  if (director) {
    alaqil_AcquirePtr($result, director->alaqil_release_ownership(%as_voidptr(*$input)));
  }
}

%typemap(directorout,noblock=1,warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) 
  alaqilTYPE &(void *alaqil_argp, int alaqil_res, alaqil_owntype own) {
  alaqil_res = alaqil_ConvertPtrAndOwn($input, &alaqil_argp, $descriptor, %convertptr_flags | alaqil_POINTER_DISOWN, &own);
  if (!alaqil_IsOK(alaqil_res)) {
    %dirout_fail(alaqil_res,"$type");
  }
  if (!alaqil_argp) { %dirout_nullref("$type"); }
  $result = %reinterpret_cast(alaqil_argp, $ltype);
  alaqil_acquire_ownership_obj(%as_voidptr($result), own /* & TODO: alaqil_POINTER_OWN */);
}
%typemap(directorfree,noblock=1,match="directorout") alaqilTYPE & {
  if (director) {
    alaqil_AcquirePtr($result, director->alaqil_release_ownership(%as_voidptr($input)));
  }
}

%typemap(directorout,noblock=1,warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) 
  alaqilTYPE &&(void *alaqil_argp, int alaqil_res, alaqil_owntype own) {
  alaqil_res = alaqil_ConvertPtrAndOwn($input, &alaqil_argp, $descriptor, %convertptr_flags | alaqil_POINTER_DISOWN, &own);
  if (!alaqil_IsOK(alaqil_res)) {
    %dirout_fail(alaqil_res,"$type");
  }
  if (!alaqil_argp) { %dirout_nullref("$type"); }
  $result = %reinterpret_cast(alaqil_argp, $ltype);
  alaqil_acquire_ownership_obj(%as_voidptr($result), own /* & TODO: alaqil_POINTER_OWN */);
}
%typemap(directorfree,noblock=1,match="directorout") alaqilTYPE && {
  if (director) {
    alaqil_AcquirePtr($result, director->alaqil_release_ownership(%as_voidptr($input)));
  }
}

#endif /* alaqil_DIRECTOR_TYPEMAPS */


/* ------------------------------------------------------------
 * --- Constants ---
 * ------------------------------------------------------------ */

%typemap(constcode,noblock=1) alaqilTYPE *, alaqilTYPE &, alaqilTYPE &&, alaqilTYPE [] {
  %set_constant("$symname", alaqil_NewPointerObj(%as_voidptr($value),$descriptor,%newpointer_flags));
}

%typemap(constcode,noblock=1) alaqilTYPE {
  %set_constant("$symname", alaqil_NewPointerObj(%as_voidptr(&$value),$&descriptor,%newpointer_flags));
}

/* ------------------------------------------------------------
 * --- Exception handling ---
 * ------------------------------------------------------------ */

%typemap(throws,noblock=1) alaqilTYPE {
  %raise(alaqil_NewPointerObj(%new_copy($1, $ltype),$&descriptor,alaqil_POINTER_OWN), "$type", $&descriptor);
}

%typemap(throws,noblock=1) alaqilTYPE * {
  %raise(alaqil_NewPointerObj(%as_voidptr($1),$descriptor,0), "$type", $descriptor);
}

%typemap(throws,noblock=1) alaqilTYPE [ANY] {
  %raise(alaqil_NewPointerObj(%as_voidptr($1),$descriptor,0), "$type", $descriptor);
}

%typemap(throws,noblock=1) alaqilTYPE & {
  %raise(alaqil_NewPointerObj(%as_voidptr(&$1),$descriptor,0), "$type", $descriptor);
}

%typemap(throws,noblock=1) alaqilTYPE && {
  %raise(alaqil_NewPointerObj(%as_voidptr(&$1),$descriptor,0), "$type", $descriptor);
}

%typemap(throws,noblock=1) (...) {
  alaqil_exception_fail(alaqil_RuntimeError,"unknown exception");
}

/* ------------------------------------------------------------
 * --- CLASS::* typemaps --- 
 * ------------------------------------------------------------ */

%typemap(in) alaqilTYPE (CLASS::*) {  
  int res = alaqil_ConvertMember($input, %as_voidptr(&$1), sizeof($type),$descriptor);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res,"$type",$symname, $argnum); 
  }
}

%typemap(out,noblock=1) alaqilTYPE (CLASS::*) {
  %set_output(alaqil_NewMemberObj(%as_voidptr(&$1), sizeof($type), $descriptor));
}

%typemap(varin) alaqilTYPE (CLASS::*) {
  int res = alaqil_ConvertMember($input,%as_voidptr(&$1), sizeof($type), $descriptor);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name"); 
  }
}

%typemap(varout,noblock=1) alaqilTYPE (CLASS::*) {
  %set_varoutput(alaqil_NewMemberObj(%as_voidptr(&$1), sizeof($type), $descriptor));
}

%typemap(constcode,noblock=1) alaqilTYPE (CLASS::*) {
  %set_constant("$symname", alaqil_NewMemberObj(%as_voidptr(&$value), sizeof($type), $descriptor));
}

#if defined(alaqil_DIRECTOR_TYPEMAPS)

/* directorin */

%typemap(directorin,noblock=1) alaqilTYPE (CLASS::*) {
  $input = alaqil_NewMemberObj(%as_voidptr(&$1), sizeof($type), $descriptor);
}

/* directorout */

%typemap(directorout) alaqilTYPE (CLASS::*) {
  int alaqil_res = alaqil_ConvertMember($input,%as_voidptr(&$result), sizeof($type), $descriptor);
  if (!alaqil_IsOK(alaqil_res)) {
    %dirout_fail(alaqil_res,"$type");
  }
}
#endif

%apply alaqilTYPE (CLASS::*) { alaqilTYPE (CLASS::*const) }
%apply alaqilTYPE & { alaqilTYPE (CLASS::*const&) }

/* ------------------------------------------------------------
 * --- function ptr typemaps --- 
 * ------------------------------------------------------------ */

/*
  ISO C++ doesn't allow direct casting of a function ptr to a object
  ptr. So, maybe the ptr sizes are not the same, and we need to take
  some providences.
 */
%typemap(in) alaqilTYPE ((*)(ANY)) {
  int res = alaqil_ConvertFunctionPtr($input, (void**)(&$1), $descriptor);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res,"$type",$symname, $argnum); 
  }
}

%typecheck(alaqil_TYPECHECK_POINTER,noblock=1) alaqilTYPE ((*)(ANY)) {
  void *ptr = 0;
  int res = alaqil_ConvertFunctionPtr($input, &ptr, $descriptor);
  $1 = alaqil_CheckState(res);
}


%typemap(out, noblock=1) alaqilTYPE ((*)(ANY)) {
  %set_output(alaqil_NewFunctionPtrObj((void *)($1), $descriptor));
}

%typemap(varin) alaqilTYPE ((*)(ANY)) {
  int res = alaqil_ConvertFunctionPtr($input, (void**)(&$1), $descriptor);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name"); 
  }
}

%typemap(varout,noblock=1) alaqilTYPE ((*)(ANY)) {  
  %set_varoutput(alaqil_NewFunctionPtrObj((void *)($1), $descriptor));
}

%typemap(constcode, noblock=1) alaqilTYPE ((*)(ANY)){
  %set_constant("$symname", alaqil_NewFunctionPtrObj((void *)$value, $descriptor));
}
%typemap(constcode) alaqilTYPE ((* const)(ANY)) = alaqilTYPE ((*)(ANY));

#if defined(alaqil_DIRECTOR_TYPEMAPS)

/* directorin */

%typemap(directorin,noblock=1) alaqilTYPE ((*)(ANY)) {
  $input = alaqil_NewFunctionPtrObj((void*)($1), $descriptor);
}

/* directorout */

%typemap(directorout) alaqilTYPE ((*)(ANY)) {
  int alaqil_res = alaqil_ConvertFunctionPtr($input,(void**)(&$result),$descriptor);
  if (!alaqil_IsOK(alaqil_res)) {
    %dirout_fail(alaqil_res,"$type");
  }
}
#endif

%apply alaqilTYPE ((*)(ANY)) { alaqilTYPE ((* const)(ANY)) }

%apply alaqilTYPE * { alaqilTYPE *const }

/* ------------------------------------------------------------
 * --- Special typemaps ---
 * ------------------------------------------------------------ */

/* DISOWN typemap */

%typemap(in, noblock=1) alaqilTYPE *DISOWN (int res = 0) {
  res = alaqil_ConvertPtr($input, %as_voidptrptr(&$1), $descriptor, alaqil_POINTER_DISOWN | %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %argument_fail(res,"$type", $symname, $argnum);
  }
}

%typemap(varin) alaqilTYPE *DISOWN {
  void *temp = 0;
  int res = alaqil_ConvertPtr($input, &temp, $descriptor, alaqil_POINTER_DISOWN | %convertptr_flags);
  if (!alaqil_IsOK(res)) {
    %variable_fail(res, "$type", "$name");
  }
  $1 = ($ltype) temp;
}

/* DYNAMIC typemap */

%typemap(out,noblock=1) alaqilTYPE *DYNAMIC, alaqilTYPE &DYNAMIC {
  %set_output(alaqil_NewPointerObj(%as_voidptr($1), alaqil_TypeDynamicCast($descriptor, %as_voidptrptr(&$1)), $owner | %newpointer_flags));
}

/* INSTANCE typemap */

%typemap(out,noblock=1) alaqilTYPE INSTANCE {
  %set_output(alaqil_NewInstanceObj(%new_copy($1, $1_ltype), $&1_descriptor, alaqil_POINTER_OWN | %newinstance_flags));
}

%typemap(out,noblock=1) alaqilTYPE *INSTANCE, alaqilTYPE &INSTANCE, alaqilTYPE INSTANCE[] {
  %set_output(alaqil_NewInstanceObj(%as_voidptr($1), $1_descriptor, $owner | %newinstance_flags));
}

%typemap(varout,noblock=1) alaqilTYPE *INSTANCE, alaqilTYPE INSTANCE[] {
  %set_varoutput(alaqil_NewInstanceObj(%as_voidptr($1), $1_descriptor, %newinstance_flags));
}

%typemap(varout,noblock=1) alaqilTYPE &INSTANCE {
  %set_varoutput(alaqil_NewInstanceObj(%as_voidptr($1), $1_descriptor, %newinstance_flags));
}

%typemap(varout,noblock=1) alaqilTYPE INSTANCE {
  %set_varoutput(alaqil_NewInstanceObj(%as_voidptr(&$1), $&1_descriptor, %newinstance_flags));
}

