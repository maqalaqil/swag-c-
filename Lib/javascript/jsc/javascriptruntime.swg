/* -----------------------------------------------------------------------------
 * javascriptruntime.swg
 *
 * Javascript support code
 * ----------------------------------------------------------------------------- */

%insert(runtime) %{
#include <JavaScriptCore/JavaScript.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <limits.h>
%}

%insert(runtime) "alaqilrun.swg";         /* alaqil API */
%insert(runtime) "alaqilerrors.swg";      /* alaqil errors */

%insert(runtime) "javascriptrun.swg";      /* alaqil errors */
