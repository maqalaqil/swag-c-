/* ------------------------------------------------------------
 *  Typemap specializations for Javascript
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */

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

/* Javascript types */

#define alaqil_Object                     v8::Handle<v8::Value>
#define VOID_Object                     alaqilV8_UNDEFINED()

/* Overload of the output/constant/exception/dirout handling */

/* append output */
#define alaqil_AppendOutput(result, obj) alaqilV8_AppendOutput(result, obj)

/* set constant */
#define alaqil_SetConstant(name, obj)

/* raise */
#define alaqil_Raise(obj, type, desc)  alaqil_V8_Raise(type)

/* Include the unified typemap library */
%include <typemaps/alaqiltypemaps.swg>
