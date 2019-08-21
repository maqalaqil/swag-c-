/* -----------------------------------------------------------------------------
 * mzscheme.swg
 *
 * alaqil Configuration File for MzScheme.
 * This file is parsed by alaqil before reading any other interface file.
 * ----------------------------------------------------------------------------- */

/* Include headers */
%runtime "alaqilrun.swg"     // Common C API type-checking code
%runtime "alaqilerrors.swg"  // alaqil errors
%runtime "mzrun.swg"

%define alaqil_APPEND_VALUE(value)
   values[lenv++] = value
%enddef

/* Definitions */
#define alaqil_malloc(size) alaqil_malloc(size, FUNC_NAME)
#define alaqil_free(mem) free(mem)

#define alaqil_convert_short(o)					\
  alaqil_convert_integer(o, - (1 << (8 * sizeof(short) - 1)),	\
		       (1 << (8 * sizeof(short) - 1)) - 1,	\
		       FUNC_NAME, $argnum-1, argc, argv)
#define alaqil_convert_int(o)					\
  alaqil_convert_integer(o, INT_MIN, INT_MAX,			\
		       FUNC_NAME, $argnum-1, argc, argv)
#define alaqil_convert_long(o)					\
  alaqil_convert_integer(o, LONG_MIN, LONG_MAX,			\
		       FUNC_NAME, $argnum-1, argc, argv)
#define alaqil_convert_unsigned_short(o)				\
  alaqil_convert_unsigned_integer(o, 0,				\
		       (1 << (8 * sizeof(short))) - 1,		\
		       FUNC_NAME, $argnum-1, argc, argv)
#define alaqil_convert_unsigned_int(o)				\
  alaqil_convert_unsigned_integer(o, 0, UINT_MAX,			\
		       FUNC_NAME, $argnum-1, argc, argv)
#define alaqil_convert_unsigned_long(o)				\
  alaqil_convert_unsigned_integer(o, 0, ULONG_MAX,		\
		       FUNC_NAME, $argnum-1, argc, argv)

/* Guile compatibility kludges */
#define SCM_VALIDATE_VECTOR(argnum, value) (void)0
#define SCM_VALIDATE_LIST(argnum, value) (void)0

/* Read in standard typemaps. */
%include <typemaps.i>

%insert(init) "alaqilinit.swg"

%init %{
Scheme_Object *scheme_reload(Scheme_Env *env) {
  Scheme_Env *menv = alaqil_MZSCHEME_CREATE_MENV(env);

  alaqil_InitializeModule((void *) env);
%}
