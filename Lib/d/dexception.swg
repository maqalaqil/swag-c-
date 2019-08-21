/* -----------------------------------------------------------------------------
 * dexception.swg
 *
 * Typemaps used for propagating C++ exceptions to D.
 * ----------------------------------------------------------------------------- */

// Code which is inserted into the dout typemaps and class constructors via
// excode if exceptions can be thrown.
%define alaqilEXCODE "\n  if ($imdmodule.alaqilPendingException.isPending) throw $imdmodule.alaqilPendingException.retrieve();" %enddef

%typemap(throws, canthrow=1) int,
                 long,
                 short,
                 unsigned int,
                 unsigned long,
                 unsigned short
%{ char error_msg[256];
   sprintf(error_msg, "C++ $1_type exception thrown, value: %d", $1);
   alaqil_DSetPendingException(alaqil_DException, error_msg);
   return $null; %}

%typemap(throws, canthrow=1) alaqilTYPE, alaqilTYPE &, alaqilTYPE *, alaqilTYPE [ANY],
  enum alaqilTYPE, const enum alaqilTYPE &
%{ (void)$1;
   alaqil_DSetPendingException(alaqil_DException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(throws, canthrow=1) char *
%{ alaqil_DSetPendingException(alaqil_DException, $1);
   return $null; %}
