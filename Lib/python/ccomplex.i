/* -----------------------------------------------------------------------------
 * ccomplex.i
 *
 * C complex typemaps
 * ISO C99:  7.3 Complex arithmetic <complex.h>
 * ----------------------------------------------------------------------------- */


%include <pycomplex.swg>

%{
#include <complex.h>
%}


/* C complex constructor */
#define CCplxConst(r, i) ((r) + I*(i))

%alaqil_cplxflt_convn(float complex, CCplxConst, creal, cimag);
%alaqil_cplxdbl_convn(double complex, CCplxConst, creal, cimag);
%alaqil_cplxdbl_convn(complex, CCplxConst, creal, cimag);

/* declaring the typemaps */
%typemaps_primitive(alaqil_TYPECHECK_CPLXFLT, float complex);
%typemaps_primitive(alaqil_TYPECHECK_CPLXDBL, double complex);
%typemaps_primitive(alaqil_TYPECHECK_CPLXDBL, complex);
