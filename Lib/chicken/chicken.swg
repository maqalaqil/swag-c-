/* -----------------------------------------------------------------------------
 * chicken.swg
 *
 * CHICKEN configuration module.
 * ----------------------------------------------------------------------------- */

/* chicken.h has to appear first. */

%insert(runtime) %{
#include <assert.h>
#include <chicken.h>
%}

%insert(runtime) "alaqilrun.swg"          // Common C API type-checking code
%insert(runtime) "alaqilerrors.swg"       // alaqil errors
%insert(runtime) "chickenrun.swg"       // CHICKEN run-time code

/* -----------------------------------------------------------------------------
 *                          standard typemaps
 * ----------------------------------------------------------------------------- */

/*
  CHICKEN: C
  ----------

  fixnum: int, short, unsigned int, unsigned short, unsigned char,
  signed char

  char: char

  bool: bool

  flonum: float, double, long, long long, unsigned long, unsigned long
  long
 */

/* --- Primitive types --- */

%define SIMPLE_TYPEMAP(type_, from_scheme, to_scheme, checker, convtype, storage_)

%typemap(in) type_ 
%{  if (!checker ($input)) {
    alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, "Argument #$argnum is not of type 'type_'");
  }
  $1 = ($1_ltype) from_scheme ($input); %}

/* Const primitive references.  Passed by value */

%typemap(in) const type_ & ($*1_ltype temp)
%{  if (!checker ($input)) {
    alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, "Argument #$argnum is not of type 'type_'");
  }
  temp = ($*1_ltype) from_scheme ($input); 
  $1 = &temp; %}

/* --- Variable input --- */
%typemap(varin) type_
%{  if (!checker ($input)) {
    alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, "Cannot use '$1_ltype' for variable '$name' of type 'type_'");
  }
  $1 = ($1_ltype) from_scheme ($input); %}

#if "storage_" == "0"

%typemap(out) type_ 
%{
  $result = to_scheme (convtype ($1));
%}

/* References to primitive types.  Return by value */

%typemap(out) const type_ &
%{
  $result = to_scheme (convtype (*$1));
%}

/* --- Variable output --- */
%typemap(varout) type_ 
%{
  $result = to_scheme (convtype ($varname));
%}

%typemap(throws) type_
%{
  alaqil_Chicken_ThrowException(to_scheme ( convtype ($1)));
%}

#else

%typemap(out) type_ 
%{
  {
  C_word *space = C_alloc(storage_);
  $result = to_scheme (&space, convtype ($1));
  }
%}

/* References to primitive types.  Return by value */

%typemap(out) const type_ &
%{
  {
  C_word *space = C_alloc(storage_);
  $result = to_scheme (&space, convtype (*$1));
  }
%}

/* --- Variable output --- */
%typemap(varout) type_ 
%{
  {
  C_word *space = C_alloc(storage_);
  $result = to_scheme (&space, convtype ($varname));
  }
%}

%typemap(throws) type_
%{
  {
  C_word *space = C_alloc(storage_);
  alaqil_Chicken_ThrowException(to_scheme (&space, convtype ($1)));
  }
%}

#endif

/* --- Constants --- */

%typemap(constcode) type_
"static const $1_type $result = $value;"

%enddef

SIMPLE_TYPEMAP(int, C_num_to_int, C_fix, C_alaqil_is_number, (int), 0);
//SIMPLE_TYPEMAP(enum alaqilTYPE, C_unfix, C_fix, C_alaqil_is_fixnum, (int), 0);
SIMPLE_TYPEMAP(short, C_num_to_int, C_fix, C_alaqil_is_number, (int), 0);
SIMPLE_TYPEMAP(long, C_num_to_long, C_long_to_num, C_alaqil_is_long, (long), C_SIZEOF_FLONUM);
SIMPLE_TYPEMAP(long long, C_num_to_long, C_long_to_num, C_alaqil_is_long, (long), C_SIZEOF_FLONUM);
SIMPLE_TYPEMAP(unsigned int, C_num_to_unsigned_int, C_unsigned_int_to_num, C_alaqil_is_number, (unsigned int), C_SIZEOF_FLONUM);
SIMPLE_TYPEMAP(unsigned short, C_num_to_unsigned_int, C_fix, C_alaqil_is_number, (unsigned int), 0);
SIMPLE_TYPEMAP(unsigned long, C_num_to_unsigned_long, C_unsigned_long_to_num, C_alaqil_is_long, (unsigned long), C_SIZEOF_FLONUM);
SIMPLE_TYPEMAP(unsigned long long, C_num_to_unsigned_long, C_unsigned_long_to_num, C_alaqil_is_long, (unsigned long), C_SIZEOF_FLONUM);
SIMPLE_TYPEMAP(unsigned char, C_character_code, C_make_character, C_alaqil_is_char, (unsigned int), 0);
SIMPLE_TYPEMAP(signed char, C_character_code, C_make_character, C_alaqil_is_char, (int), 0);
SIMPLE_TYPEMAP(char, C_character_code, C_make_character, C_alaqil_is_char, (char), 0);
SIMPLE_TYPEMAP(bool, C_truep, C_mk_bool, C_alaqil_is_bool, (bool), 0);
SIMPLE_TYPEMAP(float, C_c_double, C_flonum, C_alaqil_is_number, (double), C_SIZEOF_FLONUM);
SIMPLE_TYPEMAP(double, C_c_double, C_flonum, C_alaqil_is_number, (double), C_SIZEOF_FLONUM);

/* enum alaqilTYPE */
%apply int { enum alaqilTYPE };
%apply const int& { const enum alaqilTYPE& };
%apply const int& { const enum alaqilTYPE&& };

%typemap(varin) enum alaqilTYPE
{
  if (!C_alaqil_is_fixnum($input) && sizeof(int) != sizeof($1)) {
    alaqil_barf(alaqil_BARF1_BAD_ARGUMENT_TYPE, "enum variable '$name' can not be set");
  }
  *((int *)(void *)&$1) = C_unfix($input);
}


/* --- Input arguments --- */

/* Strings */

%typemap(in) char * 
{ if ($input == C_SCHEME_FALSE) {
  $1 = NULL;
 }
 else { 
   if (!C_alaqil_is_string ($input)) {
     alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, "Argument #$argnum is not of type 'char *'");
   }
   $1 = ($ltype) alaqil_MakeString ($input);
 }
}

%typemap(freearg) char * "if ($1 != NULL) { free ($1); }"

/* Pointers, references, and arrays */
%typemap(in,closcode="(slot-ref $input 'alaqil-this)") alaqilTYPE *, alaqilTYPE [], alaqilTYPE &, alaqilTYPE &&  {
   $1 = ($1_ltype)alaqil_MustGetPtr($input, $descriptor, $argnum, $disown);
}

%typemap(in,closcode="(slot-ref $input 'alaqil-this)") alaqilTYPE *DISOWN {
  $1 = ($1_ltype)alaqil_MustGetPtr($input, $descriptor, $argnum, alaqil_POINTER_DISOWN);
}

/* Void pointer.  Accepts any kind of pointer */
%typemap(in) void * {
  $1 = ($1_ltype)alaqil_MustGetPtr($input, NULL, $argnum, 0);
}

%typemap(varin,closcode="(slot-ref $input 'alaqil-this)") alaqilTYPE * {
  $1 = ($1_ltype)alaqil_MustGetPtr($input, $descriptor, 1, alaqil_POINTER_DISOWN);
}

%typemap(varin,closcode="(slot-ref $input 'alaqil-this)") alaqilTYPE & {
  $1 = *(($1_ltype)alaqil_MustGetPtr($input, $descriptor, 1, 0));
}

%typemap(varin,closcode="(slot-ref $input 'alaqil-this)") alaqilTYPE && {
  $1 = *(($1_ltype)alaqil_MustGetPtr($input, $descriptor, 1, 0));
}

%typemap(varin) alaqilTYPE [] {
  alaqil_Chicken_Barf(alaqil_BARF1_BAD_ARGUMENT_TYPE, "Type error");
}

%typemap(varin) alaqilTYPE [ANY] {
  void *temp;
  int ii;
  $1_basetype *b = 0;
  temp = alaqil_MustGetPtr($input, $1_descriptor, 1, 0);
  b = ($1_basetype *) $1;
  for (ii = 0; ii < $1_size; ii++) b[ii] = *(($1_basetype *) temp + ii);
}

%typemap(varin) void * {
  $1 = alaqil_MustGetPtr($input, NULL, 1, 0);
}

%typemap(out) alaqilTYPE *, alaqilTYPE &, alaqilTYPE &&, alaqilTYPE [] {
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  $result = alaqil_NewPointerObj($1, $descriptor, $owner);
}

%typemap(out) alaqilTYPE *DYNAMIC, alaqilTYPE &DYNAMIC {
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  alaqil_type_info *ty = alaqil_TypeDynamicCast($1_descriptor,(void **) &$1);
  $result = alaqil_NewPointerObj($1, ty, $owner);
}
    
%typemap(varout) alaqilTYPE *, alaqilTYPE [] {
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  $result = alaqil_NewPointerObj($varname, $descriptor, 0);
}

%typemap(varout) alaqilTYPE & {
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  $result = alaqil_NewPointerObj((void *) &$varname, $1_descriptor, 0);
}

%typemap(varout) alaqilTYPE && {
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  $result = alaqil_NewPointerObj((void *) &$varname, $1_descriptor, 0);
}

/* special typemaps for class pointers */
%typemap(in) alaqilTYPE (CLASS::*) {
  char err_msg[256];

  if (C_alaqil_is_pair($input)) {
    /* try and convert pointer object */
    void *result;
    if (!alaqil_ConvertPtr(C_block_item($input,1), &result, $descriptor, 0)) {
      C_word ptr = C_block_item($input,0);
      if (C_alaqil_is_string(ptr)) {
        alaqil_UnpackData(C_c_string(ptr), (void *) &$1, sizeof($type));
      } else {
        snprintf(err_msg, sizeof(err_msg), "Type error in argument #%i: expected %s", $argnum, ($descriptor->str ? $descriptor->str : $descriptor->name));
        alaqil_Chicken_Barf(alaqil_BARF1_BAD_ARGUMENT_TYPE, err_msg);
      }
    } else {
      snprintf(err_msg, sizeof(err_msg), "Type error in argument #%i: expected %s", $argnum, ($descriptor->str ? $descriptor->str : $descriptor->name));
      alaqil_Chicken_Barf(alaqil_BARF1_BAD_ARGUMENT_TYPE, err_msg);
    }
  } else {
    snprintf(err_msg, sizeof(err_msg), "Type error in argument #%i: expected %s", $argnum, ($descriptor->str ? $descriptor->str : $descriptor->name));
    alaqil_Chicken_Barf(alaqil_BARF1_BAD_ARGUMENT_TYPE, err_msg);
  }
}

%typemap(out) alaqilTYPE (CLASS::*) {
  size_t ptr_size = sizeof($type);
  C_word *known_space = C_alloc(C_SIZEOF_PAIR + C_SIZEOF_STRING(2*ptr_size) + C_SIZEOF_alaqil_POINTER);
  char *temp = (char *)malloc(2*ptr_size);
  C_word ptr = alaqil_NewPointerObj((void *) known_space, $descriptor, 0);

  alaqil_PackData(temp, (void *) &$1, ptr_size);
  $result = C_pair(&known_space, C_string(&known_space, 2*ptr_size, temp), ptr);
  free(temp);
}

%typemap(varin) alaqilTYPE (CLASS::*) {
  char err_msg[256];

  if (C_alaqil_is_pair($input)) {
    /* try and convert pointer object */
    void *result;
    if (!alaqil_ConvertPtr(C_block_item($input,1), &result, $descriptor, 0)) {
      C_word ptr = C_block_item($input,0);
      if (C_alaqil_is_string(ptr)) {
        alaqil_UnpackData(C_c_string(ptr), (void *) &$1, sizeof($type));
      } else {
        snprintf(err_msg, sizeof(err_msg), "Type error in argument #%i: expected %s", 1, ($descriptor->str ? $descriptor->str : $descriptor->name));
        alaqil_Chicken_Barf(alaqil_BARF1_BAD_ARGUMENT_TYPE, err_msg);
      }
    } else {
      snprintf(err_msg, sizeof(err_msg), "Type error in argument #%i: expected %s", 1, ($descriptor->str ? $descriptor->str : $descriptor->name));
      alaqil_Chicken_Barf(alaqil_BARF1_BAD_ARGUMENT_TYPE, err_msg);
    }
  } else {
    snprintf(err_msg, sizeof(err_msg), "Type error in argument #%i: expected %s", 1, ($descriptor->str ? $descriptor->str : $descriptor->name));
    alaqil_Chicken_Barf(alaqil_BARF1_BAD_ARGUMENT_TYPE, err_msg);
  }
}

%typemap(varout) alaqilTYPE (CLASS::*) {
  size_t ptr_size = sizeof($type);
  C_word *known_space = C_alloc(C_SIZEOF_PAIR + C_SIZEOF_STRING(2*ptr_size) + C_SIZEOF_alaqil_POINTER);
  char *temp = (char *)malloc(2*ptr_size);
  C_word ptr = alaqil_NewPointerObj((void *) known_space, $descriptor, 0);

  alaqil_PackData(temp, (void *) &$varname, ptr_size);
  $result = C_pair(&known_space, C_string(&known_space, 2*ptr_size, temp), ptr);
  free(temp);
}

  

/* Pass-by-value */

%typemap(in,closcode="(slot-ref $input 'alaqil-this)") alaqilTYPE($&1_ltype argp) {
  argp = ($&1_ltype)alaqil_MustGetPtr($input, $&1_descriptor, $argnum, 0);
  $1 = *argp;
}

%typemap(varin,closcode="(slot-ref $input 'alaqil-this)") alaqilTYPE {
  $&1_ltype argp;
  argp = ($&1_ltype)alaqil_MustGetPtr($input, $&1_descriptor, 1, 0);
  $1 = *argp;
}

%typemap(out) alaqilTYPE 
#ifdef __cplusplus
{
  $&1_ltype resultptr;
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  resultptr = new $1_ltype((const $1_ltype &) $1);
  $result =  alaqil_NewPointerObj(resultptr, $&1_descriptor, 1);
} 
#else
{
  $&1_ltype resultptr;
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  $result = alaqil_NewPointerObj(resultptr, $&1_descriptor, 1);
}
#endif

%typemap(varout) alaqilTYPE 
#ifdef __cplusplus
{
  $&1_ltype resultptr;
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  resultptr = new $1_ltype((const $1_ltype&) $1);
  $result =  alaqil_NewPointerObj(resultptr, $&1_descriptor, 0);
} 
#else
{
  $&1_ltype resultptr;
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  resultptr = ($&1_ltype) malloc(sizeof($1_type));
  memmove(resultptr, &$1, sizeof($1_type));
  $result = alaqil_NewPointerObj(resultptr, $&1_descriptor, 0);
}
#endif

/* --- Output values --- */

/* Strings */

%typemap(out) 
  char *
{ char *s = (char*) $1;
  if ($1 == NULL) {
    $result = C_SCHEME_FALSE;
  } 
  else {
    int string_len = strlen ((char *) ($1));
    C_word *string_space = C_alloc (C_SIZEOF_STRING (string_len));
    $result = C_string (&string_space, string_len, s);
  }
}

%typemap(varout) 
  char *
{ char *s = (char*) $varname;
  if ($varname == NULL) {
    $result = C_SCHEME_FALSE;
  } 
  else {
    int string_len = strlen ($varname);
    C_word *string_space = C_alloc (C_SIZEOF_STRING (string_len));
    $result = C_string (&string_space, string_len, s);
  }
}

%typemap(throws) char *
{ 
  if ($1 == NULL) {
    alaqil_Chicken_ThrowException(C_SCHEME_FALSE);
  } else {
    int string_len = strlen($1);
    C_word *string_space = C_alloc(C_SIZEOF_STRING(string_len));
    alaqil_Chicken_ThrowException(C_string(&string_space, string_len, (char *) $1));
  }
}

/* Void */
%typemap(out) void
%{
$result = C_SCHEME_UNDEFINED;
%}

/* Special typemap for character array return values */

%typemap(out) 
  char [ANY], const char [ANY] 
%{ if ($1 == NULL) {
  $result = C_SCHEME_FALSE;
 }
 else {
   const int string_len = strlen ($1);
   C_word *string_space = C_alloc (C_SIZEOF_STRING (string_len));
   $result = C_string (&string_space, string_len, $1);
 } %}

/* Primitive types--return by value */

/* --- Variable input --- */

/* A string */
#ifdef __cplusplus
%typemap(varin) char * {
  if ($input == C_SCHEME_FALSE) {
    $1 = NULL;
  }
  else if (!C_alaqil_is_string ($input)) {
      alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, "C variable '$name ($1_ltype)'");
  }
  else {
    char *temp = C_c_string ($input);
    int  len   = C_header_size ($input);
    if ($1) delete [] $1;
    $1 = ($type) new char[len+1];
    strncpy((char*)$1, temp, len);
    ((char*)$1) [len] = 0;
  }
}
%typemap(varin,warning="451:Setting const char * variable may leak memory") const char * {
  if ($input == C_SCHEME_FALSE) {
    $1 = NULL;
  }
  else if (!C_alaqil_is_string ($input)) {
    alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, "C variable '$name ($1_ltype)'");
  }
  else {
    char *temp = C_c_string ($input);
    int  len   = C_header_size ($input);
    $1 = ($type) new char[len+1];
    strncpy((char*)$1,temp,len);
    ((char*)$1) [len] = 0;
  }
}
#else
%typemap(varin) char * {
  if ($input == C_SCHEME_FALSE) {
    $1 = NULL;
  }
  else if (!C_alaqil_is_string ($input)) {
    alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, "C variable '$name ($1_ltype)'");
  }
  else {
    char *temp = C_c_string ($input);
    int  len   = C_header_size ($input);
    if ($1) free((char*) $1);
    $1 = ($type) malloc(len+1);
    strncpy((char*)$1,temp,len);
    ((char*)$1) [len] = 0;
  }
}
%typemap(varin,warning="451:Setting const char * variable may leak memory") const char * {
  if ($input == C_SCHEME_FALSE) {
    $1 = NULL;
  }
  else if (!C_alaqil_is_string ($input)) {
    alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, "C variable '$name ($1_ltype)'");
  }
  else {
    char *temp = C_c_string ($input);
    int  len   = C_header_size ($input);
    $1 = ($type) malloc(len+1);
    strncpy((char*)$1,temp,len);
    ((char*)$1) [len] = 0;
  }
}
#endif

%typemap(varin) char [] {
  alaqil_barf(alaqil_BARF1_BAD_ARGUMENT_TYPE, "C/C++ variable '$name' is read-only");
}

/* Special case for string array variables */
%typemap(varin) char [ANY] {
  if ($input == C_SCHEME_FALSE) {
    memset($1,0,$1_dim0*sizeof(char));
  }
  else if (!C_alaqil_is_string ($input)) {
    alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, "C variable '$name ($1_ltype)'");
  }
  else {
    char *temp = C_c_string ($input);
    strncpy($1,temp,$1_dim0*sizeof(char));
  }
}

/* --- Variable output --- */

/* Void */
%typemap(varout) void "$result = C_SCHEME_UNDEFINED;";

/* Special typemap for character array return values */
%typemap(varout) char [ANY], const char [ANY] 
%{  if ($varname == NULL) {
    $result = C_SCHEME_FALSE;
  }
  else {
   const int string_len = strlen ($varname);
   C_word *string_space = C_alloc (C_SIZEOF_STRING (string_len));
   $result = C_string (&string_space, string_len, (char *) $varname);
  }
%}


/* --- Constants --- */

%typemap(constcode) char *
"static const char *$result = $value;"

%typemap(constcode) alaqilTYPE *, alaqilTYPE &, alaqilTYPE &&, alaqilTYPE []
"static const void *$result = (void*) $value;"

/* ------------------------------------------------------------
 * String & length
 * ------------------------------------------------------------ */

%typemap(in) (char *STRING, int LENGTH), (char *STRING, size_t LENGTH) {
  if ($input == C_SCHEME_FALSE) {
    alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, "Cannot use a null/#f string for a char*, int arguments");
  }
  else if (C_alaqil_is_string ($input)) {
    $1 = ($1_ltype) C_c_string ($input);
    $2 = ($2_ltype) C_header_size ($input);
  }
  else {
    alaqil_barf (alaqil_BARF1_BAD_ARGUMENT_TYPE, "Argument #$argnum is not of type 'string'");
  }
}

/* ------------------------------------------------------------
 * CHICKEN types
 * ------------------------------------------------------------ */

%typemap(in)   C_word "$1 = $input;";
%typemap(out)  C_word "$result = $1;";

/* ------------------------------------------------------------
 * Typechecking rules
 * ------------------------------------------------------------ */

%typecheck(alaqil_TYPECHECK_INTEGER)
         bool, const bool & 
{
  $1 = C_alaqil_is_bool ($input);
}

%typecheck(alaqil_TYPECHECK_INTEGER)
	 int, short, 
 	 unsigned int, unsigned short,
	 signed char, unsigned char,
	 const int &, const short &, 
 	 const unsigned int &, const unsigned short &,
	 enum alaqilTYPE
{
  $1 = C_alaqil_is_fixnum ($input);
}

%typecheck(alaqil_TYPECHECK_INTEGER)
	 long,
 	 unsigned long,
	 long long, unsigned long long,
	 const long &,
 	 const unsigned long &,
	 const long long &, const unsigned long long &
{
  $1 = (C_alaqil_is_bool ($input) || 
    C_alaqil_is_fixnum ($input) || 
    C_alaqil_is_flonum ($input)) ? 1 : 0;
}

%typecheck(alaqil_TYPECHECK_DOUBLE)
	float, double,
	const float &, const double &
{
  $1 = C_alaqil_is_flonum ($input);
}

%typecheck(alaqil_TYPECHECK_CHAR) char {
  $1 = C_alaqil_is_string ($input);
}

%typecheck(alaqil_TYPECHECK_STRING) char * {
  $1 = C_alaqil_is_string ($input);
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE *, alaqilTYPE [] {
  void *ptr;
  $1 = !alaqil_ConvertPtr($input, &ptr, $1_descriptor, 0);
}

%typecheck(alaqil_TYPECHECK_VOIDPTR) void * {
  void *ptr;
  $1 = !alaqil_ConvertPtr($input, &ptr, 0, 0);
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE &
{
  void *ptr = 0;
  if (alaqil_ConvertPtr($input, &ptr, $descriptor, alaqil_POINTER_NO_NULL)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE &&
{
  void *ptr = 0;
  if (alaqil_ConvertPtr($input, &ptr, $descriptor, alaqil_POINTER_NO_NULL)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE 
{
  void *ptr = 0;
  if (alaqil_ConvertPtr($input, &ptr, $&descriptor, alaqil_POINTER_NO_NULL)) {
    $1 = 0;
  } else {
    $1 = 1;
  }
}


/* ------------------------------------------------------------
 * Exception handling
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 * --- Exception handling ---
 * ------------------------------------------------------------ */

%typemap(throws) alaqilTYPE {
  $&ltype temp = new $ltype($1);
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  C_word ptr = alaqil_NewPointerObj(temp, $&descriptor,1);
  alaqil_Chicken_ThrowException(ptr);
}

%typemap(throws) alaqilTYPE * {
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  C_word ptr = alaqil_NewPointerObj((void *) $1, $descriptor, 0);
  alaqil_Chicken_ThrowException(ptr);
}

%typemap(throws) alaqilTYPE [ANY] {
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  C_word ptr = alaqil_NewPointerObj((void *) $1, $descriptor, 0);
  alaqil_Chicken_ThrowException(ptr);
}

%typemap(throws) alaqilTYPE & {
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  C_word ptr = alaqil_NewPointerObj((void *)&($1),$descriptor,0);
  alaqil_Chicken_ThrowException(ptr);
}

%typemap(throws) alaqilTYPE && {
  C_word *known_space = C_alloc(C_SIZEOF_alaqil_POINTER);
  C_word ptr = alaqil_NewPointerObj((void *)&($1),$descriptor,0);
  alaqil_Chicken_ThrowException(ptr);
}

/* ------------------------------------------------------------
 * ANSI C typemaps
 * ------------------------------------------------------------ */

%apply unsigned long { size_t };

/* ------------------------------------------------------------
 * Various
 * ------------------------------------------------------------ */

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
%rename(__add__)      *::operator+;
%rename(__pos__)      *::operator+();
%rename(__pos__)      *::operator+() const;
%rename(__sub__)      *::operator-;
%rename(__neg__)      *::operator-();
%rename(__neg__)      *::operator-() const;
%rename(__mul__)      *::operator*;
%rename(__div__)      *::operator/;
%rename(__mod__)      *::operator%;
%rename(__lshift__)   *::operator<<;
%rename(__rshift__)   *::operator>>;
%rename(__and__)      *::operator&;
%rename(__or__)       *::operator|;
%rename(__xor__)      *::operator^;
%rename(__invert__)   *::operator~;
%rename(__iadd__)     *::operator+=;
%rename(__isub__)     *::operator-=;
%rename(__imul__)     *::operator*=;
%rename(__idiv__)     *::operator/=;
%rename(__imod__)     *::operator%=;
%rename(__ilshift__)  *::operator<<=;
%rename(__irshift__)  *::operator>>=;
%rename(__iand__)     *::operator&=;
%rename(__ior__)      *::operator|=;
%rename(__ixor__)     *::operator^=;
%rename(__lt__)       *::operator<;
%rename(__le__)       *::operator<=;
%rename(__gt__)       *::operator>;
%rename(__ge__)       *::operator>=;
%rename(__eq__)       *::operator==;
%rename(__ne__)       *::operator!=;

/* Special cases */
%rename(__call__)     *::operator();

#endif
/* Warnings for certain CHICKEN keywords */
%include <chickenkw.swg>

/* TinyCLOS <--> Low-level CHICKEN */

%typemap("clos_in") SIMPLE_CLOS_OBJECT * "(slot-ref $input (quote this))"
%typemap("clos_out") SIMPLE_CLOS_OBJECT * "(make $class (quote this) $1)"

%insert(header) %{
#ifdef __cplusplus
extern "C" {
#endif
/* Chicken initialization function */
alaqilEXPORT void alaqil_init(C_word, C_word, C_word) C_noret;
#ifdef __cplusplus
}
#endif
%}

%insert(closprefix) "alaqilclosprefix.scm"

%insert(init) "alaqilinit.swg"

%insert(init) %{
/* CHICKEN initialization function */
#ifdef __cplusplus
extern "C" {
#endif
alaqilEXPORT void alaqil_init(C_word argc, C_word closure, C_word continuation) {
  int       i;
  C_word sym;
  C_word tmp;
  C_word *a;
  C_word ret;
  C_word *return_vec;

  alaqil_InitializeModule(0);
  alaqil_PropagateClientData();
  ret = C_SCHEME_TRUE;
  
#if $veclength
  return_vec = C_alloc(C_SIZEOF_VECTOR($veclength));
  ret = (C_word) return_vec;
  *(return_vec++) = C_VECTOR_TYPE | $veclength;
#endif

  a = C_alloc(2*$nummethods$symsize);

%}
