/* -----------------------------------------------------------------------------
 * pike.swg
 *
 * Pike configuration module.
 * ----------------------------------------------------------------------------- */

%insert(runtime) "alaqilrun.swg";            // Common C API type-checking code
%insert(runtime) "pikerun.swg";         // Pike run-time code

%insert(runtime) %{
#ifdef __cplusplus
extern "C" {
#endif
#include <pike/global.h>
#include <pike/module.h>
#include <pike/interpret.h>
#ifdef __cplusplus
}
#endif
%}

/* -----------------------------------------------------------------------------
 *                          standard typemaps
 * ----------------------------------------------------------------------------- */

/* --- Input arguments --- */

/* Primitive datatypes. */

%typemap(in, pikedesc="tInt")
    int, unsigned int, short, unsigned short,
    long, unsigned long, char, signed char, unsigned char,
    bool, enum alaqilTYPE, long long, unsigned long long
{
    if ($input.type != T_INT)
        Pike_error("Bad argument: Expected an integer.\n");
    $1 = ($1_ltype) $input.u.integer;
}

%typemap(in, pikedesc="tFloat") float, double {
    if ($input.type != T_FLOAT)
        Pike_error("Bad argument: Expected a float.\n");
    $1 = ($1_ltype) $input.u.float_number;
}

%typemap(in, pikedesc="tStr") char *, char [ANY] {
    if ($input.type != T_STRING)
        Pike_error("Bad argument: Expected a string.\n");
    $1 = ($1_ltype) STR0($input.u.string);
}

/* Pointers, references and arrays */

%typemap(in) alaqilTYPE *,
             alaqilTYPE &,
             alaqilTYPE &&,
             alaqilTYPE []
	"alaqil_ConvertPtr($input.u.object, (void **) &$1, $1_descriptor, 1);"
	
/* Void pointer.  Accepts any kind of pointer */
%typemap(in) void * "/* FIXME */";

/* Object passed by value. Convert to a pointer */
%typemap(in) alaqilTYPE ($&1_ltype argp) "/* FIXME */";

/* Pointer to a class member */
%typemap(in) alaqilTYPE (CLASS::*) "/* FIXME */";

/* Const primitive references.  Passed by value */

%typemap(in, pikedesc="tInt") const int & (int temp),
	     const short & (short temp),
             const long  & (long temp),
             const unsigned int & (unsigned int temp),
             const unsigned short & (unsigned short temp),
             const unsigned long & (unsigned long temp),
	     const char & (char temp),
             const signed char & (signed char temp),
             const unsigned char & (unsigned char temp),
             const bool & (bool temp),
	     const long long & ($*1_ltype temp),
	     const unsigned long long & ($*1_ltype temp),
             const enum alaqilTYPE & ($*1_ltype temp),
             const enum alaqilTYPE && ($*1_ltype temp)
{
  if ($input.type != T_INT)
    Pike_error("Bad argument: Expected an integer.\n");
    temp = ($*1_ltype) $input.u.integer;
    $1 = &temp;
}

%typemap(in, pikedesc="tFloat") const float & (float temp),
	     const double & (double temp)
{
  if ($input.type != T_FLOAT)
    Pike_error("Bad argument: Expected a float.\n");
    temp = ($*1_ltype) $input.u.float_number;
    $1 = &temp;
}

/* -----------------------------------------------------------------------------
 * Output Typemaps
 * ----------------------------------------------------------------------------- */
%typemap(out, pikedesc="tInt")
    int, unsigned int,
    short, unsigned short,
    long, unsigned long,
    char, signed char, unsigned char, 
    bool, enum alaqilTYPE
	"push_int($1);";

%typemap(out, pikedesc="tInt") long long	"push_int64($1);";
%typemap(out, pikedesc="tInt") unsigned long long	"push_int64($1);";
%typemap(out, pikedesc="tFloat") float, double	"push_float($1);";
%typemap(out, pikedesc="tStr") char *		"push_text($1);";

/* Pointers, references, and arrays */
%typemap(out, pikedesc="tObj") alaqilTYPE*, alaqilTYPE &, alaqilTYPE &&, alaqilTYPE [] "push_object(alaqil_NewPointerObj((void *) $1, $1_descriptor, $owner));";

/* Void return value; don't push anything */
%typemap(out, pikedesc="tVoid") void		"";

/* Dynamic casts */

%typemap(out) alaqilTYPE *DYNAMIC, alaqilTYPE &DYNAMIC "/* FIXME */";

/* Member pointer */
%typemap(out) alaqilTYPE (CLASS::*) "/* FIXME */";

/* Special typemap for character array return values */
%typemap(out, pikedesc="tStr") char [ANY], const char [ANY] "push_text($1);";

/* Primitive types--return by value */
%typemap(out, pikedesc="tObj") alaqilTYPE 
#ifdef __cplusplus
{
  $&1_ltype resultptr;
  resultptr = new $1_ltype((const $1_ltype &) $1);
  push_object(alaqil_NewPointerObj((void *) resultptr, $&1_descriptor, 1));
}
#else
{
  $&1_ltype resultptr;
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  push_object(alaqil_NewPointerObj((void *) resultptr, $&1_descriptor, 1));
}
#endif

/* References to primitive types.  Return by value */

%typemap(out, pikedesc="tInt") const int &, const unsigned int &,
              const short &, const unsigned short &,
              const long &, const unsigned long &,
              const char &, const signed char &, const unsigned char &,
              const bool &,
	      const long long &, const unsigned long long &,
              const enum alaqilTYPE & ($*1_ltype temp),
              const enum alaqilTYPE && ($*1_ltype temp)
      "push_int(*($1));";

%typemap(out, pikedesc="tFloat") const float &, const double &  "push_float(*($1));";

/************************ Constant Typemaps *****************************/

%typemap(constant)
    int, unsigned int,
    short, unsigned short,
    long, unsigned long,
    signed char, unsigned char, 
    bool, enum alaqilTYPE,
    long long, unsigned long long
    	"add_integer_constant(\"$symname\", $1, 0);";

%typemap(constant) char
	"add_integer_constant(\"$symname\", '$1', 0);";

%typemap(constant) long long, unsigned long long
	"add_integer_constant(\"$symname\", $1, 0);";

%typemap(constant) float, double
	"add_float_constant(\"$symname\", $1, 0);";

%typemap(constant) char *
	"add_string_constant(\"$symname\", \"$1\", 0);";

/* ------------------------------------------------------------
 * String & length
 * ------------------------------------------------------------ */

%typemap(in) (char *STRING, int LENGTH), (char *STRING, size_t LENGTH) {
    if ($input.type != T_STRING)
        Pike_error("Bad argument: Expected a string.\n");
    $1 = ($1_ltype) STR0($input.u.string);
    $2 = ($2_ltype) $input.u.string->length;
}

/* ------------------------------------------------------------
 * ANSI C typemaps
 * ------------------------------------------------------------ */

%typemap(in, pikedesc="tInt") size_t {
    if ($input.type != T_INT)
        Pike_error("Bad argument: Expected an integer.\n");
    $1 = ($1_ltype) $input.u.integer;
}

%typemap(out)      size_t = long;

/* ------------------------------------------------------------
 * Typechecking rules
 * ------------------------------------------------------------ */

%typecheck(alaqil_TYPECHECK_INTEGER)
	 int, short, long,
 	 unsigned int, unsigned short, unsigned long,
	 signed char, unsigned char,
	 long long, unsigned long long,
	 const int &, const short &, const long &,
 	 const unsigned int &, const unsigned short &, const unsigned long &,
	 const long long &, const unsigned long long &,
	 enum alaqilTYPE, enum alaqilTYPE &, alaqilTYPE &&,
         bool, const bool & 
{
  $1 = ($input.type == T_INT) ? 1 : 0;
}

%typecheck(alaqil_TYPECHECK_DOUBLE)
	float, double,
	const float &, const double &
{
  $1 = (($input.type == T_FLOAT) || ($input.type == T_INT)) ? 1 : 0;
}

%typecheck(alaqil_TYPECHECK_CHAR) char {
  $1 = ($input.type == T_INT) ? 1 : 0;
}

%typecheck(alaqil_TYPECHECK_STRING) char * {
  $1 = ($input.type == T_STRING) ? 1 : 0;
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE *, alaqilTYPE &, alaqilTYPE &&, alaqilTYPE [] {
  void *ptr;
  if (alaqil_ConvertPtr($input.u.object, (void **) &ptr, $1_descriptor, 0) == -1) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE {
  void *ptr;
  if (alaqil_ConvertPtr($input.u.object, (void **) &ptr, $&1_descriptor, 0) == -1) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(alaqil_TYPECHECK_VOIDPTR) void * {
  void *ptr;
  if (alaqil_ConvertPtr($input.u.object, (void **) &ptr, 0, 0) == -1) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

/* Array reference typemaps */
%apply alaqilTYPE & { alaqilTYPE ((&)[ANY]) }
%apply alaqilTYPE && { alaqilTYPE ((&&)[ANY]) }

/* const pointers */
%apply alaqilTYPE * { alaqilTYPE *const }
%apply alaqilTYPE (CLASS::*) { alaqilTYPE (CLASS::*const) }
%apply alaqilTYPE & { alaqilTYPE (CLASS::*const&) }

/* ------------------------------------------------------------
 * Overloaded operator support
 * ------------------------------------------------------------ */

#ifdef __cplusplus
%rename("`+")      *::operator+;
%rename("`-")      *::operator-;
%rename("`*")      *::operator*;
%rename("`/")      *::operator/;
%rename("`%")      *::operator%;
%rename("`<<")     *::operator<<;
%rename("`>>")     *::operator>>;
%rename("`&")      *::operator&;
%rename("`|")      *::operator|;
%rename("`^")      *::operator^;
%rename("`~")      *::operator~;
%rename("`<")      *::operator<;
%rename("`>")      *::operator>;
%rename("`==")     *::operator==;

/* Special cases */
%rename("`()")     *::operator();

#endif

/* ------------------------------------------------------------
 * The start of the Pike initialization function
 * ------------------------------------------------------------ */

%init "alaqilinit.swg"

%init %{
#ifdef __cplusplus
extern "C"
#endif
PIKE_MODULE_EXIT {}

#ifdef __cplusplus
extern "C"
#endif
PIKE_MODULE_INIT
{
    struct program *pr;
    alaqil_InitializeModule(0);
%}

/* pike keywords */
%include <pikekw.swg>
