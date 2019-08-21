/* ------------------------------------------------------------
 *  Typemap specializations for Tcl
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */

/*
  In Tcl we need to pass the interp value, so we define the decl/call
  macros as needed.
*/

#define alaqil_AS_DECL_ARGS alaqil_TCL_DECL_ARGS_2
#define alaqil_AS_CALL_ARGS alaqil_TCL_CALL_ARGS_2


/* Include fundamental fragment definitions */
%include <typemaps/fragments.swg>

/* Look for user fragments file. */
%include <tclfragments.swg>

/* Tcl fragments for primitive types */
%include <tclprimtypes.swg>

/* Tcl fragments for char* strings */
%include <tclstrings.swg>


/* ------------------------------------------------------------
 *  Unified typemap section
 * ------------------------------------------------------------ */

/* No director support in Tcl */
#ifdef alaqil_DIRECTOR_TYPEMAPS
#undef alaqil_DIRECTOR_TYPEMAPS
#endif


/* Tcl types */
#define alaqil_Object                      Tcl_Obj *

/* Overload of the output/constant/exception handling */

/* output */
#define %set_output(obj)                 Tcl_SetObjResult(interp,obj)

/* append output */
#define %append_output(obj)              Tcl_ListObjAppendElement(interp,Tcl_GetObjResult(interp),obj)

/* set constant */
#define alaqil_SetConstant(name, obj)      alaqil_Tcl_SetConstantObj(interp, name, obj)

/* raise */
#define alaqil_Raise(obj,type,desc)        alaqil_Tcl_SetErrorObj(interp,type,obj)


/* Include the unified typemap library */
%include <typemaps/alaqiltypemaps.swg>


/* ------------------------------------------------------------
 *  Tcl extra typemaps / typemap overrides
 * ------------------------------------------------------------ */

#if 1
// Old 1.3.25 typemaps needed to avoid premature object deletion
%typemap(out,noblock=1) alaqilTYPE *INSTANCE, alaqilTYPE &INSTANCE, alaqilTYPE &&INSTANCE, alaqilTYPE INSTANCE[] {
  Tcl_SetObjResult(interp, alaqil_NewInstanceObj( %as_voidptr($1), $1_descriptor,0));
}

%typemap(out) alaqilTYPE *DYNAMIC, alaqilTYPE &DYNAMIC {
  alaqil_type_info *ty = alaqil_TypeDynamicCast($1_descriptor,%as_voidptrptr(&$1));
  Tcl_SetObjResult(interp,alaqil_NewInstanceObj(%as_voidptr($1), ty,0));
}

#endif

%typemap(throws,noblock=1) alaqilTYPE CLASS {
  alaqil_set_result(alaqil_NewInstanceObj(%as_voidptr(alaqil_new_copy($1, $1_ltype)), $&1_descriptor, 1));
  alaqil_fail;
}

%typemap(out)    alaqilTYPE    =  alaqilTYPE INSTANCE;
%typemap(out)    alaqilTYPE *  =  alaqilTYPE *INSTANCE;
%typemap(out)    alaqilTYPE *const  =  alaqilTYPE *;
%typemap(out)    alaqilTYPE &  =  alaqilTYPE &INSTANCE;
%typemap(out)    alaqilTYPE && =  alaqilTYPE &&INSTANCE;
%typemap(out)    alaqilTYPE [] =  alaqilTYPE INSTANCE[];
%typemap(varout) alaqilTYPE    =  alaqilTYPE INSTANCE;
