/*  ------------------------------------------------------------
 *
 * Define the IN/OUTPUT typemaps assuming the output parameters are
 * returned in a list, i.e., they are not directly modified.
 *
 * The user should provide the %append_output(result, obj) method,
 * via a macro, which append a particular object to the result.
 *
 *
 * In Tcl, for example, the file is used as:
 *
 *   #define %append_output(obj) Tcl_ListObjAppendElement(interp,Tcl_GetObjResult(interp),obj);
 *   %include <typemaps/inoutlist.swg>
 *
 * while in Python it is used as:
 *
 *   #define %append_output(obj) $result = alaqil_Python_AppendResult($result, obj)
 *   %include <typemaps/inoutlist.swg>
 *
 * where the method alaqil_Python_AppendResult is defined inside the
 * %append_output fragment.
 *
 * If you forget to define %append_output, this file will generate
 * an error.
 *
 * ------------------------------------------------------------ */


//
// Uncomment the following definition if you don't want the in/out
// typemaps by default, ie, you prefer to use typemaps.i.
//
//#define alaqil_INOUT_NODEF

//
// Use the following definition to enable the INPUT parameters to
// accept both 'by value' and 'pointer' objects.
//
#define alaqil_INPUT_ACCEPT_PTRS

// ------------------------------------------------------------------------
// Pointer handling
//
// These mappings provide support for input/output arguments and common
// uses for C/C++ pointers.
// ------------------------------------------------------------------------

// INPUT typemaps.
// These remap a C pointer to be an "INPUT" value which is passed by value
// instead of reference.

/* 
The following methods can be applied to turn a pointer into a simple
"input" value.  That is, instead of passing a pointer to an object,
you would use a real value instead.
         
To use these, suppose you had a C function like this :

        double fadd(double *a, double *b) {
               return *a+*b;
        }

You could wrap it with alaqil as follows :

        double fadd(double *INPUT, double *INPUT);

or you can use the %apply directive :

        %apply double *INPUT { double *a, double *b };
        double fadd(double *a, double *b);

*/
#if defined(alaqil_INPUT_ACCEPT_PTRS)
#define %check_input_ptr(input,arg,desc,disown) (alaqil_IsOK((res = alaqil_ConvertPtr(input,%as_voidptrptr(arg),desc,disown))))
#else
#define %check_input_ptr(input,arg,desc,disown) (alaqil_IsOK((res = alaqil_ERROR)))
#endif

%define %_value_input_typemap(code, asval_meth, asval_frag, Type)
  %typemap(in,noblock=1,fragment=asval_frag) Type *INPUT ($*ltype temp, int res = 0) {
    if (!%check_input_ptr($input,&$1,$descriptor,$disown)) {
      Type val; 
      int ecode = asval_meth($input, &val);
      if (!alaqil_IsOK(ecode)) { 
	%argument_fail(ecode, "$*ltype",$symname, $argnum);
      }
      temp = %static_cast(val, $*ltype);
      $1 = &temp;
      res = alaqil_AddTmpMask(ecode);
    }
  }
  %typemap(in,noblock=1,fragment=asval_frag) Type &INPUT($*ltype temp, int res = 0) {
    if (!%check_input_ptr($input,&$1,$descriptor,$disown)) {
      Type val;
      int ecode = asval_meth($input, &val);
      if (!alaqil_IsOK(ecode)) { 
	%argument_fail(ecode, "$*ltype",$symname, $argnum);
      }
      temp = %static_cast(val, $*ltype);
      $1 = &temp;
      res = alaqil_AddTmpMask(ecode);
    }
  }
  %typemap(freearg,noblock=1,match="in") Type *INPUT, Type &INPUT {
    if (alaqil_IsNewObj(res$argnum)) %delete($1);
  }
  %typemap(typecheck,noblock=1,precedence=code,fragment=asval_frag) Type *INPUT, Type &INPUT {
    void *ptr = 0;
    int res = asval_meth($input, 0);
    $1 = alaqil_CheckState(res);
    if (!$1) {
      $1 = %check_input_ptr($input,&ptr,$1_descriptor,0);
    }
  }
%enddef

%define %_ptr_input_typemap(code,asptr_meth,asptr_frag,Type)
  %typemap(in,noblock=1,fragment=asptr_frag) Type *INPUT(int res = 0) {  
    res = asptr_meth($input, &$1);
    if (!alaqil_IsOK(res)) {
      %argument_fail(res,"$type",$symname, $argnum);
    }
    res = alaqil_AddTmpMask(res);
  }
  %typemap(in,noblock=1,fragment=asptr_frag) Type &INPUT(int res = 0) {  
    res = asptr_meth($input, &$1);
    if (!alaqil_IsOK(res)) { 
      %argument_fail(res,"$type",$symname, $argnum);
    }     
    if (!$1) { 
      %argument_nullref("$type",$symname, $argnum);
    }
    res = alaqil_AddTmpMask(res);
  }
  %typemap(freearg,noblock=1,match="in") Type *INPUT, Type &INPUT {
    if (alaqil_IsNewObj(res$argnum)) %delete($1);
  }
  %typemap(typecheck,noblock=1,precedence=code,fragment=asptr_frag) Type *INPUT, Type &INPUT {
    int res = asptr_meth($input, (Type**)0);
    $1 = alaqil_CheckState(res);
  }
%enddef

// OUTPUT typemaps.   These typemaps are used for parameters that
// are output only.   The output value is appended to the result as
// a list element.

/* 
The following methods can be applied to turn a pointer into an "output"
value.  When calling a function, no input value would be given for
a parameter, but an output value would be returned.  In the case of
multiple output values, they are returned in the form of a list.

         
For example, suppose you were trying to wrap the modf() function in the
C math library which splits x into integral and fractional parts (and
returns the integer part in one of its parameters):

        double modf(double x, double *ip);

You could wrap it with alaqil as follows :

        double modf(double x, double *OUTPUT);

or you can use the %apply directive :

        %apply double *OUTPUT { double *ip };
        double modf(double x, double *ip);

The output of the function would be a list containing both output
values.

*/

%define %_value_output_typemap(from_meth, from_frag, Type)
 %typemap(in,numinputs=0,noblock=1) 
   Type *OUTPUT ($*1_ltype temp, int res = alaqil_TMPOBJ), 
   Type &OUTPUT ($*1_ltype temp, int res = alaqil_TMPOBJ) {
   $1 = &temp;
 }
 %typemap(argout,noblock=1,fragment=from_frag) Type *OUTPUT, Type &OUTPUT {
   if (alaqil_IsTmpObj(res$argnum)) {
     %append_output(from_meth((*$1)));
   } else {
     int new_flags = alaqil_IsNewObj(res$argnum) ? (alaqil_POINTER_OWN | %newpointer_flags) : %newpointer_flags;
     %append_output(alaqil_NewPointerObj((void*)($1), $1_descriptor, new_flags));
   }
 }
%enddef


// INOUT
// Mappings for an argument that is both an input and output
// parameter

/*
The following methods can be applied to make a function parameter both
an input and output value.  This combines the behavior of both the
"INPUT" and "OUTPUT" methods described earlier.  Output values are
returned in the form of a list.  
         
For example, suppose you were trying to wrap the following function :

        void neg(double *x) {
             *x = -(*x);
        }

You could wrap it with alaqil as follows :

        void neg(double *INOUT);

or you can use the %apply directive :

        %apply double *INOUT { double *x };
        void neg(double *x);

Unlike C, this mapping does not directly modify the input value.
Rather, the modified input value shows up as the return value of the
function.  Thus, to apply this function to a variable you might do
this :

       x = neg(x)

Note : previous versions of alaqil used the symbol 'BOTH' to mark
input/output arguments.   This is still supported, but will be slowly
phased out in future releases.

*/

%define %_value_inout_typemap(Type)
 %typemap(in) Type *INOUT = Type *INPUT;
 %typemap(in) Type &INOUT = Type &INPUT;
 %typemap(typecheck) Type *INOUT = Type *INPUT;
 %typemap(typecheck) Type &INOUT = Type &INPUT;
 %typemap(argout) Type *INOUT = Type *OUTPUT;
 %typemap(argout) Type &INOUT = Type &OUTPUT;
%enddef


%define %_ptr_inout_typemap(Type)
 %_value_inout_typemap(%arg(Type))
 %typemap(typecheck) Type *INOUT = Type *INPUT;
 %typemap(typecheck) Type &INOUT = Type &INPUT;
 %typemap(freearg) Type *INOUT = Type *INPUT;
 %typemap(freearg) Type &INOUT = Type &INPUT;
%enddef

#ifndef alaqil_INOUT_NODEF

%define %value_input_typemap(code,asval_meth, asval_frag, Type...)
  %_value_input_typemap(%arg(code),%arg(asval_meth),%arg(asval_frag),%arg(Type))
%enddef

%define %ptr_input_typemap(code,asval_meth,asval_frag,Type...)		
  %_ptr_input_typemap(%arg(code),%arg(asval_meth),%arg(asval_frag),%arg(Type))
%enddef

%define %value_output_typemap(from_meth,from_frag,Type...)		
  %_value_output_typemap(%arg(from_meth),%arg(from_frag),%arg(Type))
%enddef

#define %value_inout_typemap(Type...) %_value_inout_typemap(%arg(Type))
#define %ptr_inout_typemap(Type...) %_ptr_inout_typemap(%arg(Type))

#else /* You need to include typemaps.i */


#define %value_output_typemap(Type...)
#define %value_input_typemap(Type...)
#define %value_inout_typemap(Type...)
#define %ptr_input_typemap(Type...)
#define %ptr_inout_typemap(Type...)

#endif /* alaqil_INOUT_DEFAULT */

/*----------------------------------------------------------------------
  Front ends.
  
  use the following macros to define your own IN/OUTPUT/INOUT typemaps
  
  ------------------------------------------------------------------------*/
%define %typemaps_inout(Code, AsValMeth, FromMeth, AsValFrag, FromFrag, Type...)
  %_value_input_typemap(%arg(Code), %arg(AsValMeth), 
			    %arg(AsValFrag), %arg(Type));
  %_value_output_typemap(%arg(FromMeth), %arg(FromFrag), %arg(Type));
  %_value_inout_typemap(%arg(Type));
%enddef

%define %typemaps_inoutn(Code,Type...)
  %typemaps_inout(%arg(Code),
		 %arg(alaqil_AsVal(Type)), 
		 %arg(alaqil_From(Type)), 
		 %arg(alaqil_AsVal_frag(Type)), 
		 %arg(alaqil_From_frag(Type)), 
		 %arg(Type));
%enddef
