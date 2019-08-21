/* -----------------------------------------------------------------------------
 * const.i
 *
 * Typemaps for constants
 * ----------------------------------------------------------------------------- */

%typemap(consttab) int,
                   unsigned int,
                   short,
                   unsigned short,
                   long,
                   unsigned long,
                   unsigned char,
                   signed char,
                   enum alaqilTYPE
  "alaqil_LONG_CONSTANT($symname, ($1_type)$value);";

%typemap(consttab) bool
  "alaqil_BOOL_CONSTANT($symname, ($1_type)$value);";

%typemap(consttab) float,
                   double
  "alaqil_DOUBLE_CONSTANT($symname, $value);";

%typemap(consttab) char
  "alaqil_CHAR_CONSTANT($symname, $value);";

%typemap(consttab) char *,
                   const char *,
                   char [],
                   const char []
  "alaqil_STRING_CONSTANT($symname, $value);";

%typemap(consttab) alaqilTYPE *,
                   alaqilTYPE &,
                   alaqilTYPE &&,
                   alaqilTYPE [] {
  zend_constant c;
  alaqil_SetPointerZval(&c.value, (void*)$value, $1_descriptor, 0);
  zval_copy_ctor(&c.value);
  c.name = zend_string_init("$symname", sizeof("$symname") - 1, 0);
  alaqil_ZEND_CONSTANT_SET_FLAGS(&c, CONST_CS, module_number);
  zend_register_constant(&c);
}

/* Handled as a global variable. */
%typemap(consttab) alaqilTYPE (CLASS::*) "";
