/*---------------------------------------------------------------------
 * Value typemaps (Type, const Type&) for value types, such as
 * fundamental types (int, double), that define the AsVal/From
 * methods.
 *
 * To apply them, just use one of the following macros:
 *
 *   %typemaps_from(FromMeth, FromFrag, Type)
 *   %typemaps_asval(CheckCode, AsValMeth, AsValFrag, Type)
 *   %typemaps_asvalfrom(CheckCode, AsValMeth, FromMeth, AsValFrag, FromFrag, Type)
 *
 * or the simpler and normalize form:
 *
 *   %typemaps_asvalfromn(CheckCode, Type)
 *
 * Also, you can use the individual typemap definitions:
 *
 *    %value_in_typemap(asval_meth,frag,Type)
 *    %value_varin_typemap(asval_meth,frag,Type)
 *    %value_typecheck_typemap(checkcode,asval_meth,frag,Type)
 *    %value_directorout_typemap(asval_meth,frag,Type)
 *
 *    %value_out_typemap(from_meth,frag,Type)
 *    %value_varout_typemap(from_meth,frag,Type)
 *    %value_constcode_typemap(from_meth,frag,Type)
 *    %value_directorin_typemap(from_meth,frag,Type)
 *    %value_throws_typemap(from_meth,frag,Type)
 *
 *---------------------------------------------------------------------*/

/* in */

%define %value_in_typemap(asval_meth,frag,Type...)
  %typemap(in,noblock=1,fragment=frag) Type (Type val, int ecode = 0) {
    ecode = asval_meth($input, &val);
    if (!alaqil_IsOK(ecode)) {
      %argument_fail(ecode, "$ltype", $symname, $argnum);
    } 
    $1 = %static_cast(val,$ltype);
  }
  %typemap(freearg) Type "";
  %typemap(in,noblock=1,fragment=frag) const Type & ($*ltype temp, Type val, int ecode = 0) {  
    ecode = asval_meth($input, &val);
    if (!alaqil_IsOK(ecode)) {
      %argument_fail(ecode, "$*ltype", $symname, $argnum);
    } 
    temp = %static_cast(val, $*ltype);
    $1 = &temp;
  }
  %typemap(freearg) const Type& "";
%enddef

/* out */

%define %value_out_typemap(from_meth,frag,Type...)
  %typemap(out,noblock=1,fragment=frag) Type, const Type {
    %set_output(from_meth(%static_cast($1,Type))); 
  }
  %typemap(out,noblock=1,fragment=frag) const Type& {
    %set_output(from_meth(%static_cast(*$1,Type))); 
  }
%enddef

/* varin */

%define %value_varin_typemap(asval_meth,frag,Type...)
  %typemap(varin,fragment=frag) Type {
    Type val;
    int res = asval_meth($input, &val);
    if (!alaqil_IsOK(res)) {
      %variable_fail(res, "$type", "$name");
    }
    $1 = %static_cast(val,$ltype);
  }
%enddef

/* varout */

%define %value_varout_typemap(from_meth,frag,Type...)
  %typemap(varout,noblock=1,fragment=frag) Type, const Type&  {
    %set_varoutput(from_meth(%static_cast($1,Type)));
  }
%enddef

/* constant installation code */

%define %value_constcode_typemap(from_meth,frag,Type...)
  %typemap(constcode,noblock=1,fragment=frag) Type {
    %set_constant("$symname", from_meth(%static_cast($value,Type)));
  }
%enddef


#if defined(alaqil_DIRECTOR_TYPEMAPS)

/* directorin */

%define %value_directorin_typemap(from_meth,frag,Type...)
  %typemap(directorin,noblock=1,fragment=frag) Type *DIRECTORIN {
    $input = from_meth(%static_cast(*$1,Type)); 
  }
  %typemap(directorin,noblock=1,fragment=frag) Type, const Type& {
    $input = from_meth(%static_cast($1,Type)); 
  }
%enddef

/* directorout */

%define %value_directorout_typemap(asval_meth,frag,Type...)
  %typemap(directorargout,noblock=1,fragment=frag) Type *DIRECTOROUT(Type alaqil_val, int alaqil_res) {
    alaqil_res = asval_meth($result, &alaqil_val);
    if (!alaqil_IsOK(alaqil_res)) {
      %dirout_fail(alaqil_res, "$type");
    } 
    *$1 = alaqil_val;
  }
  %typemap(directorout,noblock=1,fragment=frag) Type {
    Type alaqil_val;
    int alaqil_res = asval_meth($input, &alaqil_val);
    if (!alaqil_IsOK(alaqil_res)) {
      %dirout_fail(alaqil_res, "$type");
    }
    $result = %static_cast(alaqil_val,$type);
  }
  %typemap(directorout,noblock=1,fragment=frag,warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) const Type& {  
    Type alaqil_val;
    int alaqil_res = asval_meth($input, &alaqil_val);
    if (!alaqil_IsOK(alaqil_res)) {
      %dirout_fail(alaqil_res, "$type");
    } 
    $basetype *temp = new $basetype(($basetype)alaqil_val);
    alaqil_acquire_ownership(temp);
    $result = temp;
  }
  %typemap(directorfree,noblock=1) const Type & {
    if (director) {
      director->alaqil_release_ownership(%as_voidptr($input));
    }
  }
  %typemap(directorout,fragment=frag) Type &DIRECTOROUT = Type
%enddef

#else

#define %value_directorin_typemap(from_meth,frag,Type...)
#define %value_directorout_typemap(asval_meth,frag,Type...)

#endif /* alaqil_DIRECTOR_TYPEMAPS */


/* throws */

%define %value_throws_typemap(from_meth,frag,Type...)
  %typemap(throws,noblock=1,fragment=frag) Type {
    %raise(from_meth(%static_cast($1,Type)), "$type", 0);
  }
%enddef

/* typecheck */

%define %value_typecheck_typemap(check,asval_meth,frag,Type...)
  %typemap(typecheck,precedence=check,fragment=frag) Type, const Type& {
    int res = asval_meth($input, NULL);
    $1 = alaqil_CheckState(res);
  }
%enddef

/*---------------------------------------------------------------------
 * typemap definition for types with AsVal methods
 *---------------------------------------------------------------------*/
%define %typemaps_asval(CheckCode, AsValMeth, AsValFrag, Type...)
  %value_in_typemap(%arg(AsValMeth), %arg(AsValFrag), Type);
  %value_varin_typemap(%arg(AsValMeth), %arg(AsValFrag), Type);
  %value_directorout_typemap(%arg(AsValMeth), %arg(AsValFrag), Type);
  %value_typecheck_typemap(%arg(CheckCode), %arg(AsValMeth), %arg(AsValFrag), Type);
  %value_input_typemap(%arg(CheckCode), %arg(AsValMeth), %arg(AsValFrag), Type);
%enddef


/*---------------------------------------------------------------------
 * typemap definition for types with from method
 *---------------------------------------------------------------------*/
%define %typemaps_from(FromMeth, FromFrag, Type...)
  %value_out_typemap(%arg(FromMeth), %arg(FromFrag), Type);
  %value_varout_typemap(%arg(FromMeth), %arg(FromFrag), Type);
  %value_constcode_typemap(%arg(FromMeth), %arg(FromFrag), Type);
  %value_directorin_typemap(%arg(FromMeth), %arg(FromFrag), Type);
  %value_throws_typemap(%arg(FromMeth), %arg(FromFrag), Type);
  %value_output_typemap(%arg(FromMeth), %arg(FromFrag), Type);
%enddef


/*---------------------------------------------------------------------
 * typemap definition for types with alval/from method
 *---------------------------------------------------------------------*/

%define %typemaps_asvalfrom(CheckCode, AsValMeth, FromMeth,
			   AsValFrag, FromFrag, Type...)
  %typemaps_asval(%arg(CheckCode), %arg(AsValMeth), %arg(AsValFrag), Type);
  %typemaps_from(%arg(FromMeth), %arg(FromFrag), Type);
  %value_inout_typemap(Type);
%enddef


/*---------------------------------------------------------------------
 * typemap definition for types  with for 'normalized' asval/from methods
 *---------------------------------------------------------------------*/
%define %typemaps_asvalfromn(CheckCode, Type...)
  %typemaps_asvalfrom(%arg(CheckCode),
		     alaqil_AsVal(Type), 
		     alaqil_From(Type), 
		     %arg(alaqil_AsVal_frag(Type)),
		     %arg(alaqil_From_frag(Type)), 
		     Type);
%enddef
