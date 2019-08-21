/* ------------------------------------------------------------
 *  Typemap specializations for Javascript
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */

/* These macros are necessary to provide an extra parameter
   to alaqil_AsVal_dec functions (JSContextRef context).
   They must be defined before including `typemaps/fragments.swg`
*/
#define alaqil_FROM_DECL_ARGS alaqil_JSC_FROM_DECL_ARGS
#define alaqil_FROM_CALL_ARGS alaqil_JSC_FROM_CALL_ARGS
#define alaqil_AS_DECL_ARGS alaqil_JSC_AS_DECL_ARGS
#define alaqil_AS_CALL_ARGS alaqil_JSC_AS_CALL_ARGS

/* Include fundamental fragemt definitions */
%include <typemaps/fragments.swg>

/* Look for user fragments file. */
%include <javascriptfragments.swg>

/* Javascript fragments for fundamental types */
%include <javascriptprimtypes.swg>

/* Javascript fragments for char* strings */
%include <javascriptstrings.swg>

/* ------------------------------------------------------------
 *  Unified typemap section
 * ------------------------------------------------------------ */

#define alaqil_Object                     JSValueRef
#define VOID_Object                     JSValueMakeUndefined(context)

/* append output */
#define alaqil_AppendOutput(result, obj) alaqilJSC_AppendOutput(context, result, obj)

/* set constant */
#define alaqil_SetConstant(name, obj)

/* raise */
#define alaqil_Raise(obj, type, desc)  alaqil_Javascript_Raise(context, exception, type)

%insert("runtime") %{
#define alaqil_JSC_FROM_DECL_ARGS(arg1)              (JSContextRef context, arg1)
#define alaqil_JSC_FROM_CALL_ARGS(arg1)              (context, arg1)
#define alaqil_JSC_AS_DECL_ARGS(arg1, arg2)          (JSContextRef context, arg1, arg2)
#define alaqil_JSC_AS_CALL_ARGS(arg1, arg2)          (context, arg1, arg2)
%}

/* Include the unified typemap library */
%include <typemaps/alaqiltypemaps.swg>
