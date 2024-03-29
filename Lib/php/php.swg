/* -----------------------------------------------------------------------------
 * php.swg
 *
 * PHP configuration file
 * ----------------------------------------------------------------------------- */

%runtime "alaqilrun.swg"  // Common C API type-checking code
%runtime "alaqilerrors.swg"    // alaqil errors
%runtime "phprun.swg"	// PHP runtime functions

%include <phpinit.swg> // PHP initialization routine.

%include <globalvar.i>	// Global variables.
%include <const.i>

// use %init %{ "/*code goes here*/ " %}
// or  %minit %{ "/* code goes here*/ " %} to
// insert code in the PHP_MINIT_FUNCTION
#define %minit %insert("init")

// use %rinit %{ "/* code goes here*/ " %} to
// insert code in the PHP_RINIT_FUNCTION
#define %rinit %insert("rinit")

// use %shutdown %{ " /*code goes here*/ " %} to
// insert code in the PHP_MSHUTDOWN_FUNCTION
#define %shutdown  %insert("shutdown")
#define %mshutdown  %insert("shutdown")

// use %rshutdown %{ " /*code goes here*/" %} to
// insert code in the PHP_RSHUTDOWN_FUNCTION
#define %rshutdown  %insert("rshutdown")

/* Typemaps for input parameters by value */

%include <utils.i>

%pass_by_val(bool,CONVERT_BOOL_IN);

%pass_by_val(size_t, CONVERT_INT_IN);

%pass_by_val(enum alaqilTYPE, CONVERT_INT_IN);

%pass_by_val(signed int, CONVERT_INT_IN);
%pass_by_val(int,CONVERT_INT_IN);
%pass_by_val(unsigned int,CONVERT_INT_IN);

%pass_by_val(signed short, CONVERT_INT_IN);
%pass_by_val(short,CONVERT_INT_IN);
%pass_by_val(unsigned short, CONVERT_INT_IN);

%pass_by_val(signed long, CONVERT_INT_IN);
%pass_by_val(long, CONVERT_INT_IN);
%pass_by_val(unsigned long, CONVERT_INT_IN);

%pass_by_val(signed long long, CONVERT_LONG_LONG_IN);
%pass_by_val(long long, CONVERT_LONG_LONG_IN);
%pass_by_val(unsigned long long, CONVERT_UNSIGNED_LONG_LONG_IN);

%pass_by_val(signed char, CONVERT_INT_IN);
%pass_by_val(char, CONVERT_CHAR_IN);
%pass_by_val(unsigned char, CONVERT_INT_IN);

%pass_by_val(float, CONVERT_FLOAT_IN);

%pass_by_val(double, CONVERT_FLOAT_IN);

%pass_by_val(char *, CONVERT_STRING_IN);
%typemap(in) char *& = const char *&;
%typemap(directorout) char *& = const char *&;

// char array can be in/out, though the passed string may not be big enough...
// so we have to size it
%typemap(in) char[ANY]
%{
   convert_to_string(&$input);
   $1 = ($1_ltype) Z_STRVAL($input);
%}

%typemap(in) (char *STRING, int LENGTH), (char *STRING, size_t LENGTH) %{
   convert_to_string(&$input);
   $1 = ($1_ltype) Z_STRVAL($input);
   $2 = ($2_ltype) Z_STRLEN($input);
%}

/* Object passed by value. Convert to a pointer */
%typemap(in) alaqilTYPE ($&1_ltype tmp)
%{
	if (alaqil_ConvertPtr(&$input, (void **) &tmp, $&1_descriptor, 0) < 0 || tmp == NULL) {
          alaqil_PHP_Error(E_ERROR, "Type error in argument $argnum of $symname. Expected $&1_descriptor");
	}
	$1 = *tmp;
%}

%typemap(directorout) alaqilTYPE ($&1_ltype tmp)
%{
	/* If exit was via exception, PHP NULL is returned so skip the conversion. */
	if (!EG(exception)) {
	  if (alaqil_ConvertPtr($input, (void **) &tmp, $&1_descriptor, 0) < 0 || tmp == NULL)
	    alaqil_PHP_Error(E_ERROR, "Type error in argument $argnum of $symname. Expected $&1_descriptor");
	  $result = *tmp;
	}
%}

%typemap(in) alaqilTYPE *,
	     alaqilTYPE []
%{
	if (alaqil_ConvertPtr(&$input, (void **) &$1, $1_descriptor, 0) < 0) {
            alaqil_PHP_Error(E_ERROR, "Type error in argument $argnum of $symname. Expected $1_descriptor");
	}
%}

%typemap(in) alaqilTYPE &
%{
	if (alaqil_ConvertPtr(&$input, (void **) &$1, $1_descriptor, 0) < 0 || $1 == NULL) {
	    alaqil_PHP_Error(E_ERROR, "Type error in argument $argnum of $symname. Expected $1_descriptor");
	}
%}

%typemap(in) alaqilTYPE &&
%{
	if (alaqil_ConvertPtr(&$input, (void **) &$1, $1_descriptor, 0) < 0 || $1 == NULL) {
	    alaqil_PHP_Error(E_ERROR, "Type error in argument $argnum of $symname. Expected $1_descriptor");
	}
%}

%typemap(in) alaqilTYPE *const& ($*ltype temp)
%{
	if (alaqil_ConvertPtr(&$input, (void **) &temp, $*1_descriptor, 0) < 0) {
            alaqil_PHP_Error(E_ERROR, "Type error in argument $argnum of $symname. Expected $*1_descriptor");
	}
	$1 = ($1_ltype)&temp;
%}

%typemap(in) alaqilTYPE *DISOWN
%{
  if (alaqil_ConvertPtr(&$input, (void **) &$1, $1_descriptor, alaqil_POINTER_DISOWN ) < 0) {
    alaqil_PHP_Error(E_ERROR, "Type error in argument $argnum of $symname. Expected $1_descriptor");
  }
%}

%typemap(argout) alaqilTYPE *,
                 alaqilTYPE [],
                 alaqilTYPE &,
                 alaqilTYPE &&;

%typemap(in) void *
%{
	if (alaqil_ConvertPtr(&$input, (void **) &$1, 0, 0) < 0) {
	  /* Allow NULL from php for void* */
	  if (Z_ISNULL($input)) $1=0;
	else
	  alaqil_PHP_Error(E_ERROR, "Type error in argument $argnum of $symname. Expected $1_descriptor");
	}
%}

/* Special case when void* is passed by reference so it can be made to point
   to opaque api structs */
%typemap(in) void ** ($*1_ltype ptr, int force),
             void *& ($*1_ltype ptr, int force)
{
  /* If they pass NULL by reference, make it into a void*
     This bit should go in arginit if arginit support init-ing scripting args */
  if (alaqil_ConvertPtr(&$input, (void **) &$1, $1_descriptor, 0) < 0) {
    /* So... we didn't get a ref or ptr, but we'll accept NULL by reference */
    if (!(Z_ISREF($input) && Z_ISNULL_P(Z_REFVAL($input)))) {
      /* wasn't a pre/ref/thing, OR anything like an int thing */
      alaqil_PHP_Error(E_ERROR, "Type error in argument $arg of $symname.");
    }
  }
  force=0;
  if (arg1==NULL) {
#ifdef __cplusplus
    ptr=new $*1_ltype();
#else
    ptr=($*1_ltype) calloc(1,sizeof($*1_ltype));
#endif
    $1=&ptr;
    /* have to passback arg$arg too */
    force=1;
  }
}
%typemap(argout) void **,
                 void *&
%{
  if (force$argnum) {
    alaqil_SetPointerZval(&$input, (void*) ptr$argnum, $*1_descriptor, 1);
  }
%}

/* Typemap for output values */

%typemap(out) int,
              unsigned int,
              short,
              unsigned short,
              long,
              unsigned long,
              signed char,
              unsigned char,
              bool,
              size_t
%{
  RETVAL_LONG($1);
%}

%typemap(out) enum alaqilTYPE
%{
  RETVAL_LONG((long)$1);
%}

%typemap(out) long long
%{
  if ((long long)LONG_MIN <= $1 && $1 <= (long long)LONG_MAX) {
    RETVAL_LONG((long)($1));
  } else {
    char temp[256];
    sprintf(temp, "%lld", (long long)$1);
    RETVAL_STRING(temp);
  }
%}
%typemap(out) unsigned long long
%{
  if ($1 <= (unsigned long long)LONG_MAX) {
    RETVAL_LONG((long)($1));
  } else {
    char temp[256];
    sprintf(temp, "%llu", (unsigned long long)$1);
    RETVAL_STRING(temp);
  }
%}

%typemap(out) const int &,
              const unsigned int &,
              const short &,
              const unsigned short &,
              const long &,
              const unsigned long &,
              const signed char &,
              const unsigned char &,
              const bool &,
              const size_t &
%{
  RETVAL_LONG(*$1);
%}

%typemap(out) const enum alaqilTYPE &
%{
  RETVAL_LONG((long)*$1);
%}

%typemap(out) const enum alaqilTYPE &&
%{
  RETVAL_LONG((long)*$1);
%}

%typemap(out) const long long &
%{
  if ((long long)LONG_MIN <= *$1 && *$1 <= (long long)LONG_MAX) {
    RETVAL_LONG((long)(*$1));
  } else {
    char temp[256];
    sprintf(temp, "%lld", (long long)(*$1));
    RETVAL_STRING(temp);
  }
%}
%typemap(out) const unsigned long long &
%{
  if (*$1 <= (unsigned long long)LONG_MAX) {
    RETVAL_LONG((long)(*$1));
  } else {
    char temp[256];
    sprintf(temp, "%llu", (unsigned long long)(*$1));
    RETVAL_STRING(temp);
  }
%}

%typemap(directorin) int,
              unsigned int,
              short,
              unsigned short,
              long,
              unsigned long,
              signed char,
              unsigned char,
              size_t,
              enum alaqilTYPE
%{
  ZVAL_LONG($input,$1);
%}

%typemap(directorin) enum alaqilTYPE
%{
  ZVAL_LONG($input, (long)$1_name);
%}

%typemap(directorin) char *, char []
%{
    if(!$1) {
      ZVAL_NULL($input);
    } else {
      ZVAL_STRING($input, (const char*)$1);
    }
%}

%typemap(out) bool
%{
  RETVAL_BOOL(($1) ? 1 : 0);
%}

%typemap(out) const bool &
%{
  RETVAL_BOOL((*$1) ? 1 : 0);
%}

%typemap(directorin) bool
%{
  ZVAL_BOOL($input, ($1) ? 1 : 0);
%}

%typemap(out) float,
              double
%{
  RETVAL_DOUBLE($1);
%}

%typemap(out) const float &,
              const double &
%{
  RETVAL_DOUBLE(*$1);
%}

%typemap(directorin) float,
                     double
%{
  ZVAL_DOUBLE($input, $1);
%}

%typemap(out) char
%{
  RETVAL_STRINGL(&$1, 1);
%}

%typemap(out) const char &
%{
  RETVAL_STRINGL(&*$1, 1);
%}

%typemap(out) char *,
              char []
%{
  if (!$1) {
    RETVAL_NULL();
  } else {
    RETVAL_STRING((const char *)$1);
  }
%}

%typemap(out) char *&
%{
  if (!*$1) {
    RETVAL_NULL();
  } else {
    RETVAL_STRING((const char *)*$1);
  }
%}

%typemap(out) alaqilTYPE *,
              alaqilTYPE [],
              alaqilTYPE &,
              alaqilTYPE &&
%{
  alaqil_SetPointerZval(return_value, (void *)$1, $1_descriptor, $owner);
%}

%typemap(out) alaqilTYPE *const&
%{
  alaqil_SetPointerZval(return_value, (void *)*$1, $*1_descriptor, $owner);
%}

%typemap(directorin) alaqilTYPE *,
                     alaqilTYPE [],
                     alaqilTYPE &,
                     alaqilTYPE &&
%{
  alaqil_SetPointerZval($input, (void *)&$1, $1_descriptor, ($owner)|2);
%}

%typemap(out, fragment="alaqil_php_init_member_ptr") alaqilTYPE (CLASS::*)
{
  void * p = emalloc(sizeof($1));
  memcpy(p, &$1, sizeof($1));
  RETVAL_RES(zend_register_resource(p, alaqil_member_ptr));
}

%typemap(in, fragment="alaqil_php_init_member_ptr") alaqilTYPE (CLASS::*)
{
  void * p = (void*)zend_fetch_resource_ex(&$input, alaqil_MEMBER_PTR, alaqil_member_ptr);
  memcpy(&$1, p, sizeof($1));
}

%typemap(out) alaqilTYPE *DYNAMIC,
              alaqilTYPE &DYNAMIC
{
  alaqil_type_info *ty = alaqil_TypeDynamicCast($1_descriptor, (void **) &$1);
  alaqil_SetPointerZval(return_value, (void *)$1, ty, $owner);
}

%typemap(out) alaqilTYPE
#ifdef __cplusplus
{
  $&1_ltype resultobj = new $1_ltype((const $1_ltype &) $1);
  alaqil_SetPointerZval(return_value, (void *)resultobj, $&1_descriptor, 1);
}
#else
{
  $&1_ltype resultobj = ($&1_ltype) emalloc(sizeof($1_type));
  memcpy(resultobj, &$1, sizeof($1_type));
  alaqil_SetPointerZval(return_value, (void *)resultobj, $&1_descriptor, 1);
}
#endif

%typemap(directorin) alaqilTYPE
%{
  alaqil_SetPointerZval($input, alaqil_as_voidptr(new $1_ltype((const $1_ltype &)$1)), $&1_descriptor, 1|2);
%}

%typemap(out) void "";

%typemap(out) char [ANY]
{
  int len = 0;
  while (len < $1_dim0 && $1[len]) ++len;
  RETVAL_STRINGL($1, len);
}

// This typecheck does hard checking for proper argument type.  If you want
// an argument to be converted from a different PHP type, you must convert
// it yourself before passing it (e.g. (string)4.7 or (int)"6").
%define %php_typecheck(_type,_prec,is)
%typemap(typecheck,precedence=_prec) _type, const _type &
 " $1 = (Z_TYPE($input) == is);"
%enddef

// Like %php_typecheck but allows either of two values.
%define %php_typecheck2(_type,_prec,is1,is2)
%typemap(typecheck,precedence=_prec) _type, const _type &
 " $1 = (Z_TYPE($input) == is1 || Z_TYPE($input) == is2);"
%enddef

%php_typecheck(int,alaqil_TYPECHECK_INTEGER,IS_LONG)
%php_typecheck(unsigned int,alaqil_TYPECHECK_UINT32,IS_LONG)
%php_typecheck(short,alaqil_TYPECHECK_INT16,IS_LONG)
%php_typecheck(unsigned short,alaqil_TYPECHECK_UINT16,IS_LONG)
%php_typecheck(long,alaqil_TYPECHECK_INT32,IS_LONG)
%php_typecheck(unsigned long,alaqil_TYPECHECK_UINT32,IS_LONG)
%php_typecheck(long long,alaqil_TYPECHECK_INT64,IS_LONG)
%php_typecheck(unsigned long long,alaqil_TYPECHECK_UINT64,IS_LONG)
%php_typecheck(signed char,alaqil_TYPECHECK_INT8,IS_LONG)
%php_typecheck(unsigned char,alaqil_TYPECHECK_UINT8,IS_LONG)
%php_typecheck(size_t,alaqil_TYPECHECK_SIZE,IS_LONG)
%php_typecheck(enum alaqilTYPE,alaqil_TYPECHECK_INTEGER,IS_LONG)
%php_typecheck2(bool,alaqil_TYPECHECK_BOOL,IS_TRUE,IS_FALSE)
%php_typecheck(float,alaqil_TYPECHECK_FLOAT,IS_DOUBLE)
%php_typecheck(double,alaqil_TYPECHECK_DOUBLE,IS_DOUBLE)
%php_typecheck(char,alaqil_TYPECHECK_CHAR,IS_STRING)

%typemap(typecheck,precedence=alaqil_TYPECHECK_STRING) char *, char *&, char []
 " $1 = (Z_TYPE($input) == IS_STRING); "

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE
{
  void *tmp;
  $1 = (alaqil_ConvertPtr(&$input, (void **)&tmp, $&1_descriptor, alaqil_POINTER_NO_NULL) >= 0);
}

%typecheck(alaqil_TYPECHECK_POINTER)
             alaqilTYPE *,
             alaqilTYPE [],
             alaqilTYPE *const&
{
  void *tmp;
  $1 = (alaqil_ConvertPtr(&$input, (void**)&tmp, $1_descriptor, 0) >= 0);
}

%typecheck(alaqil_TYPECHECK_POINTER)
             alaqilTYPE &,
             alaqilTYPE &&
{
  void *tmp;
  $1 = (alaqil_ConvertPtr(&$input, (void**)&tmp, $1_descriptor, alaqil_POINTER_NO_NULL) >= 0);
}

%typecheck(alaqil_TYPECHECK_POINTER) alaqilTYPE *const&
{
  void *tmp;
  $1 = (alaqil_ConvertPtr(&$input, (void**)&tmp, $*1_descriptor, 0) >= 0);
}

%typecheck(alaqil_TYPECHECK_VOIDPTR) void *
{
  void *tmp;
  $1 = (alaqil_ConvertPtr(&$input, (void**)&tmp, 0, 0) >= 0);
}

/* Exception handling */

%typemap(throws) int,
                 long,
                 short,
                 unsigned int,
                 unsigned long,
                 unsigned short %{
  zend_throw_exception(NULL, "C++ $1_type exception thrown", $1);
  return;
%}

%typemap(throws) alaqilTYPE, alaqilTYPE &, alaqilTYPE &&, alaqilTYPE *, alaqilTYPE [], alaqilTYPE [ANY] %{
  (void)$1;
  zend_throw_exception(NULL, "C++ $1_type exception thrown", 0);
  return;
%}

%typemap(throws) char * %{
  zend_throw_exception(NULL, $1, 0);
  return;
%}

/* Array reference typemaps */
%apply alaqilTYPE & { alaqilTYPE ((&)[ANY]) }
%apply alaqilTYPE && { alaqilTYPE ((&&)[ANY]) }

/* const pointers */
%apply alaqilTYPE * { alaqilTYPE *const }
%apply alaqilTYPE (CLASS::*) { alaqilTYPE (CLASS::*const) }
%apply alaqilTYPE & { alaqilTYPE (CLASS::*const&) }

/* php keywords */
%include <phpkw.swg>
