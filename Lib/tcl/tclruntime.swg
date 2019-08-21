/* tcl.h has to appear first */
%insert(runtime) %{
#include <stdio.h>
#include <tcl.h>
#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <ctype.h>
%}

%insert(runtime) "alaqilrun.swg";         /* Common C API type-checking code */
%insert(runtime) "alaqilerrors.swg"       /* alaqil errors */   
%insert(runtime) "tclerrors.swg";       /* Tcl Errors */
%insert(runtime) "tclapi.swg";          /* Tcl API */
%insert(runtime) "tclrun.swg";          /* Tcl run-time code */
