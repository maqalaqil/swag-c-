/* -----------------------------------------------------------------------------
 * ptrtypes.swg
 *
 * Value typemaps (Type, const Type&) for "Ptr" types, such as alaqil
 * wrapped classes, that define the AsPtr/From methods
 *
 * To apply them, just use one of the following macros:
 *
 *    %typemaps_asptr(CheckCode, AsPtrMeth, AsPtrFrag, Type)
 *    %typemaps_asptrfrom(CheckCode, AsPtrMeth, FromMeth, AsPtrFrag, FromFrag, Type)
 *
 * or the simpler and normalize form:
 *
 *    %typemaps_asptrfromn(CheckCode, Type)
 *
 * Also, you can use the individual typemap definitions:
 *
 *    %ptr_in_typemap(asptr_meth,frag,Type)
 *    %ptr_varin_typemap(asptr_meth,frag,Type)
 *    %ptr_typecheck_typemap(check,asptr_meth,frag,Type)
 *    %ptr_directorout_typemap(asptr_meth,frag,Type)
 * ----------------------------------------------------------------------------- */

%include <typemaps/valtypes.swg>

/* in */

%define %ptr_in_typemap(asptr_meth,frag,Type...)
  %typemap(in,fragment=frag) Type {
    Type *ptr = (Type *)0;
    int res = asptr_meth($input, &ptr);
    if (!alaqil_IsOK(res) || !ptr) { 
      %argument_fail((ptr ? res : alaqil_TypeError), "$type", $symname, $argnum); 
    }
    $1 = *ptr;
    if (alaqil_IsNewObj(res)) %delete(ptr);
  }
  %typemap(freearg) Type "";
  %typemap(in,fragment=frag) const Type & (int res = alaqil_OLDOBJ) {
    Type *ptr = (Type *)0;
    res = asptr_meth($input, &ptr);
    if (!alaqil_IsOK(res)) { %argument_fail(res,"$type",$symname, $argnum); }
    if (!ptr) { %argument_nullref("$type",$symname, $argnum); }
    $1 = ptr;
  }
  %typemap(freearg,noblock=1) const Type &  {
    if (alaqil_IsNewObj(res$argnum)) %delete($1);
  }
%enddef

/* varin */

%define %ptr_varin_typemap(asptr_meth,frag,Type...)
  %typemap(varin,fragment=frag) Type {
    Type *ptr = (Type *)0;
    int res = asptr_meth($input, &ptr);
    if (!alaqil_IsOK(res) || !ptr) { 
      %variable_fail((ptr ? res : alaqil_TypeError), "$type", "$name"); 
    }
    $1 = *ptr;
    if (alaqil_IsNewObj(res)) %delete(ptr);
  }
%enddef

#if defined(alaqil_DIRECTOR_TYPEMAPS)
/* directorout */

%define %ptr_directorout_typemap(asptr_meth,frag,Type...)
  %typemap(directorargout,noblock=1,fragment=frag) Type *DIRECTOROUT ($*ltype temp, int alaqil_ores) {
    Type *alaqil_optr = 0;
    alaqil_ores = $result ? asptr_meth($result, &alaqil_optr) : 0;
    if (!alaqil_IsOK(alaqil_ores) || !alaqil_optr) { 
      %dirout_fail((alaqil_optr ? alaqil_ores : alaqil_TypeError),"$type");
    }
    temp = *alaqil_optr;
    $1 = &temp;
    if (alaqil_IsNewObj(alaqil_ores)) %delete(alaqil_optr);
  }

  %typemap(directorout,noblock=1,fragment=frag) Type {
    Type *alaqil_optr = 0;
    int alaqil_ores = asptr_meth($input, &alaqil_optr);
    if (!alaqil_IsOK(alaqil_ores) || !alaqil_optr) { 
      %dirout_fail((alaqil_optr ? alaqil_ores : alaqil_TypeError),"$type");
    }
    $result = *alaqil_optr;
    if (alaqil_IsNewObj(alaqil_ores)) %delete(alaqil_optr);
  }

  %typemap(directorout,noblock=1,fragment=frag,warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) Type* {
    Type *alaqil_optr = 0;
    int alaqil_ores = asptr_meth($input, &alaqil_optr);
    if (!alaqil_IsOK(alaqil_ores)) { 
      %dirout_fail(alaqil_ores,"$type");
    }    
    $result = alaqil_optr;
    if (alaqil_IsNewObj(alaqil_ores)) {
      alaqil_acquire_ownership(alaqil_optr);
    }
  }
  %typemap(directorfree,noblock=1) Type*
  {
    if (director)  {
      director->alaqil_release_ownership(%as_voidptr($input));
    }
  }

  %typemap(directorout,noblock=1,fragment=frag,warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) Type& {
    Type *alaqil_optr = 0;
    int alaqil_ores = asptr_meth($input, &alaqil_optr);
    if (!alaqil_IsOK(alaqil_ores)) { 
      %dirout_fail(alaqil_ores,"$type");
    } else {
      if (!alaqil_optr) { 
	%dirout_nullref("$type");
      } 
    }    
    $result = alaqil_optr;
    if (alaqil_IsNewObj(alaqil_ores)) {
      alaqil_acquire_ownership(alaqil_optr);
    }
  }
  %typemap(directorfree,noblock=1) Type&
  {
    if (director) {
      director->alaqil_release_ownership(%as_voidptr($input));
    }
  }


  %typemap(directorout,fragment=frag) Type &DIRECTOROUT = Type

%enddef

#else

#define %ptr_directorout_typemap(asptr_meth,frag,Type...) 

#endif /* alaqil_DIRECTOR_TYPEMAPS */

/* typecheck */

%define %ptr_typecheck_typemap(check,asptr_meth,frag,Type...)
%typemap(typecheck,noblock=1,precedence=check,fragment=frag) Type * {
  int res = asptr_meth($input, (Type**)(0));
  $1 = alaqil_CheckState(res);
}

%typemap(typecheck,noblock=1,precedence=check,fragment=frag) Type, const Type& {  
  int res = asptr_meth($input, (Type**)(0));
  $1 = alaqil_CheckState(res);
}
%enddef


/*---------------------------------------------------------------------
 * typemap definition for types with asptr method
 *---------------------------------------------------------------------*/

%define %typemaps_asptr(CheckCode, AsPtrMeth, AsPtrFrag, Type...)
  %fragment(alaqil_AsVal_frag(Type),"header",fragment=alaqil_AsPtr_frag(Type)) {
    alaqilINTERNINLINE int
    alaqil_AsVal(Type)(alaqil_Object obj, Type *val)
    {
      Type *v = (Type *)0;
      int res = alaqil_AsPtr(Type)(obj, &v);
      if (!alaqil_IsOK(res)) return res;
      if (v) {
	if (val) *val = *v;
	if (alaqil_IsNewObj(res)) {
	  %delete(v);
	  res = alaqil_DelNewMask(res);
	}
	return res;
      }
      return alaqil_ERROR;
    }
  }
  %ptr_in_typemap(%arg(AsPtrMeth), %arg(AsPtrFrag), Type);
  %ptr_varin_typemap(%arg(AsPtrMeth), %arg(AsPtrFrag), Type);
  %ptr_directorout_typemap(%arg(AsPtrMeth), %arg(AsPtrFrag), Type);
  %ptr_typecheck_typemap(%arg(CheckCode), %arg(AsPtrMeth),%arg(AsPtrFrag), Type);
  %ptr_input_typemap(%arg(CheckCode),%arg(AsPtrMeth),%arg(AsPtrFrag),Type);
%enddef

/*---------------------------------------------------------------------
 * typemap definition for types with asptr/from methods
 *---------------------------------------------------------------------*/

%define %typemaps_asptrfrom(CheckCode, AsPtrMeth, FromMeth, AsPtrFrag, FromFrag, Type...)
  %typemaps_asptr(%arg(CheckCode), %arg(AsPtrMeth), %arg(AsPtrFrag), Type)
  %typemaps_from(%arg(FromMeth), %arg(FromFrag), Type);
  %value_output_typemap(%arg(FromMeth), %arg(FromFrag), Type);
  %ptr_inout_typemap(Type);
%enddef

/*---------------------------------------------------------------------
 * typemap definition for types  with for 'normalized' asptr/from methods
 *---------------------------------------------------------------------*/

%define %typemaps_asptrfromn(CheckCode, Type...)
%typemaps_asptrfrom(%arg(CheckCode),
		   %arg(alaqil_AsPtr(Type)), 
		   %arg(alaqil_From(Type)), 
		   %arg(alaqil_AsPtr_frag(Type)), 
		   %arg(alaqil_From_frag(Type)), 
		   Type);
%enddef
