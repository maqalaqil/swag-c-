/* ------------------------------------------------------------
 *  Typemap specializations for Ruby
 * ------------------------------------------------------------ */
/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */
/* bool is dangerous in Ruby, change precedence */
#undef alaqil_TYPECHECK_BOOL
%define alaqil_TYPECHECK_BOOL             10000 %enddef

/* Include fundamental fragment definitions */
%include <typemaps/fragments.swg>

/* Look for user fragments file. */
%include <rubyfragments.swg>

/* Ruby fragments for primitive types */
%include <rubyprimtypes.swg>

/* Ruby fragments for char* strings */
%include <rubystrings.swg>

/* Backward compatibility output helper */
%fragment("output_helper","header") %{
#define output_helper alaqil_Ruby_AppendOutput
%}

/* ------------------------------------------------------------
 *  Unified typemap section
 * ------------------------------------------------------------ */

/* Directors are supported in Ruby */
#ifndef alaqil_DIRECTOR_TYPEMAPS
#define alaqil_DIRECTOR_TYPEMAPS
#endif


/* Ruby types */
#define alaqil_Object                      VALUE
#define VOID_Object                      Qnil

/* Overload of the output/constant/exception handling */

/* append output */
#define alaqil_AppendOutput(result,obj)    alaqil_Ruby_AppendOutput(result, obj)

/* set constant */
#define alaqil_SetConstant(name, obj)      rb_define_const($module, name, obj)

/* raise */
#define alaqil_Raise(obj, type, desc)      rb_exc_raise(alaqil_Ruby_ExceptionType(desc, obj)) 

/* Get the address of the 'Ruby self' object */

%typemap(in,numinputs=0,noblock=1) VALUE* RUBY_SELF {
  $1 = &self;
}

/* Include the unified typemap library */
%include <typemaps/alaqiltypemaps.swg>


