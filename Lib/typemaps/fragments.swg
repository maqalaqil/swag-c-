/*
  Fragments
  =========
  See the "Typemap fragments" section in the documentation for understanding
  fragments. Below is some info on how fragments and automatic type
  specialization is used.

  Macros that make the automatic generation of typemaps easier are provided.

  Consider the following code:

      %fragment(alaqil_From_frag(bool), "header") {     
      static PyObject*		      
      alaqil_From_dec(bool)(bool value)	       
      {					       
        PyObject *obj = value ? Py_True : Py_False;  
        Py_INCREF(obj);			       
        return obj;				       
      }					       
      }					       
      					 
      %typemap(out, fragment=alaqil_From_frag(bool)) bool {
        $result = alaqil_From(bool)($1));
      }

  Here the macros

      alaqil_From_frag  => fragment 
      alaqil_From_dec   => declaration 
      alaqil_From       => call 
      
  allow you to define/include a fragment, and declare and call the
  'from-bool' method as needed. In the simpler case, these macros 
  just return something like

      alaqil_From_frag(bool)  => "alaqil_From_bool"
      alaqil_From_dec(bool)   =>  alaqil_From_bool
      alaqil_From(bool)       =>  alaqil_From_bool

  But they are specialized for the different languages requirements,
  such as perl or tcl that requires passing the interpreter pointer,
  and also they can manage C++ ugly types, for example:
  
      alaqil_From_frag(std::complex<double>)  => "alaqil_From_std_complex_Sl_double_Sg_"
      alaqil_From_dec(std::complex<double>)   =>  alaqil_From_std_complex_Sl_double_Sg_
      alaqil_From(std::complex<double>)       =>  alaqil_From_std_complex_Sl_double_Sg_


  Hence, to declare methods to use with typemaps, always use the
  alaqil_From* macros. In the same way, the alaqil_AsVal* and alaqil_AsPtr*
  set of macros are provided.
    
*/


/* -----------------------------------------------------------------------------
 * Define the basic macros to 'normalize' the type fragments
 * ----------------------------------------------------------------------------- */

#ifndef alaqil_AS_DECL_ARGS
#define alaqil_AS_DECL_ARGS
#endif

#ifndef alaqil_FROM_DECL_ARGS
#define alaqil_FROM_DECL_ARGS
#endif

#ifndef alaqil_AS_CALL_ARGS
#define alaqil_AS_CALL_ARGS
#endif

#ifndef alaqil_FROM_CALL_ARGS
#define alaqil_FROM_CALL_ARGS
#endif

#define %fragment_name(Name, Type...)     %string_name(Name) "_" {Type}

#define alaqil_Traits_frag(Type...) %fragment_name(Traits, Type) 
#define alaqil_AsPtr_frag(Type...)  %fragment_name(AsPtr, Type)	 
#define alaqil_AsVal_frag(Type...)  %fragment_name(AsVal, Type)	 
#define alaqil_From_frag(Type...)   %fragment_name(From, Type)	 

#define alaqil_AsVal_name(Type...)  %symbol_name(AsVal, Type) 
#define alaqil_AsPtr_name(Type...)  %symbol_name(AsPtr, Type) 
#define alaqil_From_name(Type...)   %symbol_name(From, Type)  

#define alaqil_AsVal_dec(Type...)   alaqil_AsVal_name(Type) alaqil_AS_DECL_ARGS
#define alaqil_AsPtr_dec(Type...)   alaqil_AsPtr_name(Type) alaqil_AS_DECL_ARGS
#define alaqil_From_dec(Type...)    alaqil_From_name(Type)  alaqil_FROM_DECL_ARGS 

#define alaqil_AsVal(Type...)       alaqil_AsVal_name(Type) alaqil_AS_CALL_ARGS 
#define alaqil_AsPtr(Type...)  	  alaqil_AsPtr_name(Type) alaqil_AS_CALL_ARGS 	 
#define alaqil_From(Type...)   	  alaqil_From_name(Type)  alaqil_FROM_CALL_ARGS 

/* ------------------------------------------------------------
 * common fragments 
 * ------------------------------------------------------------ */

%fragment("alaqil_isfinite","header",fragment="<math.h>,<float.h>") %{
/* Getting isfinite working pre C99 across multiple platforms is non-trivial. Users can provide alaqil_isfinite on older platforms. */
#ifndef alaqil_isfinite
/* isfinite() is a macro for C99 */
# if defined(isfinite)
#  define alaqil_isfinite(X) (isfinite(X))
# elif defined(__cplusplus) && __cplusplus >= 201103L
/* Use a template so that this works whether isfinite() is std::isfinite() or
 * in the global namespace.  The reality seems to vary between compiler
 * versions.
 *
 * Make sure namespace std exists to avoid compiler warnings.
 *
 * extern "C++" is required as this fragment can end up inside an extern "C" { } block
 */
namespace std { }
extern "C++" template<typename T>
inline int alaqil_isfinite_func(T x) {
  using namespace std;
  return isfinite(x);
}
#  define alaqil_isfinite(X) (alaqil_isfinite_func(X))
# elif defined(__GNUC__) && (__GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ >= 2))
#  define alaqil_isfinite(X) (__builtin_isfinite(X))
# elif defined(__clang__) && defined(__has_builtin)
#  if __has_builtin(__builtin_isfinite)
#   define alaqil_isfinite(X) (__builtin_isfinite(X))
#  endif
# elif defined(_MSC_VER)
#  define alaqil_isfinite(X) (_finite(X))
# elif defined(__sun) && defined(__SVR4)
#  include <ieeefp.h>
#  define alaqil_isfinite(X) (finite(X))
# endif
#endif
%}

%fragment("alaqil_Float_Overflow_Check","header",fragment="<float.h>,alaqil_isfinite") %{
/* Accept infinite as a valid float value unless we are unable to check if a value is finite */
#ifdef alaqil_isfinite
# define alaqil_Float_Overflow_Check(X) ((X < -FLT_MAX || X > FLT_MAX) && alaqil_isfinite(X))
#else
# define alaqil_Float_Overflow_Check(X) ((X < -FLT_MAX || X > FLT_MAX))
#endif
%}

/* -----------------------------------------------------------------------------
 * special macros for fragments
 * ----------------------------------------------------------------------------- */

/* Macros to derive numeric types */

%define %numeric_type_from(Type, Base)
%fragment(alaqil_From_frag(Type),"header",
	  fragment=alaqil_From_frag(Base)) {
alaqilINTERNINLINE alaqil_Object
alaqil_From_dec(Type)(Type value)
{    
  return alaqil_From(Base)(value);
}
}
%enddef

%define %numeric_type_asval(Type, Base, Frag, OverflowCond)
%fragment(alaqil_AsVal_frag(Type),"header",
	  fragment=Frag,
	  fragment=alaqil_AsVal_frag(Base)) {
alaqilINTERN int
alaqil_AsVal_dec(Type)(alaqil_Object obj, Type *val)
{
  Base v;
  int res = alaqil_AsVal(Base)(obj, &v);
  if (alaqil_IsOK(res)) {
    if (OverflowCond) {
      return alaqil_OverflowError;
    } else {
      if (val) *val = %numeric_cast(v, Type);
    }
  }  
  return res;
}
}
%enddef

#define %numeric_signed_type_asval(Type, Base, Frag, Min, Max) \
%numeric_type_asval(Type, Base, Frag, (v < Min || v > Max))

#define %numeric_unsigned_type_asval(Type, Base, Frag, Max) \
%numeric_type_asval(Type, Base, Frag, (v > Max))


/* Macro for 'signed long' derived types */

%define %numeric_slong(Type, Frag, Min, Max)
%numeric_type_from(Type, long)
%numeric_signed_type_asval(Type, long, Frag , Min, Max)
%enddef

/* Macro for 'unsigned long' derived types */

%define %numeric_ulong(Type, Frag, Max)
%numeric_type_from(Type, unsigned long)
%numeric_unsigned_type_asval(Type, unsigned long, Frag, Max)
%enddef


/* Macro for floating point derived types (original macro) */

%define %numeric_double(Type, Frag, Min, Max)
%numeric_type_from(Type, double)
%numeric_signed_type_asval(Type, double, Frag , Min, Max)
%enddef

/* Macro for floating point derived types */

%define %numeric_float(Type, Frag, OverflowCond)
%numeric_type_from(Type, double)
%numeric_type_asval(Type, double, Frag, OverflowCond)
%enddef


/* Macros for missing fragments */

%define %ensure_fragment(Fragment)
%fragment(`Fragment`,"header") {
%#error "alaqil language implementation must provide the Fragment fragment"
}
%enddef

%define %ensure_type_fragments(Type)
%fragment(alaqil_From_frag(Type),"header") {
%#error "alaqil language implementation must provide a alaqil_From_frag(Type) fragment"
}
%fragment(alaqil_AsVal_frag(Type),"header") {
%#error "alaqil language implementation must provide a alaqil_AsVal_frag(Type) fragment"
}
%enddef
