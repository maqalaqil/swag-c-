%insert(runtime) %{
#if defined(__GNUC__) && defined(_WIN32) && !defined(alaqil_PYTHON_NO_HYPOT_WORKAROUND)
/* Workaround for '::hypot' has not been declared', see https://bugs.python.org/issue11566 */
# include <math.h>
#endif

#if defined(_DEBUG) && defined(alaqil_PYTHON_INTERPRETER_NO_DEBUG)
/* Use debug wrappers with the Python release dll */
# undef _DEBUG
# include <Python.h>
# define _DEBUG 1
#else
# include <Python.h>
#endif
%}

%insert(runtime) "alaqilrun.swg";         /* alaqil API */
%insert(runtime) "alaqilerrors.swg";      /* alaqil errors */   
%insert(runtime) "pyhead.swg";          /* Python includes and fixes */
%insert(runtime) "pyerrors.swg";        /* Python errors */
%insert(runtime) "pythreads.swg";       /* Python thread code */
%insert(runtime) "pyapi.swg";           /* Python API */
%insert(runtime) "pyrun.swg";           /* Python run-time code */

#if defined(alaqilPYTHON_BUILTIN)
%insert(runtime) "builtin.swg";		/* Specialization for classes with single inheritance */
#endif
