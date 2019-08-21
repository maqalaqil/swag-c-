/*
  Defines the As/From converters for double/float complex, you need to
  provide complex Type, the Name you want to use in the converters,
  the complex Constructor method, and the Real and Imag complex
  accessor methods.

  See the std_complex.i and ccomplex.i for concrete examples.
*/

/* the common from converter */
%define %alaqil_fromcplx_conv(Type, Real, Imag)
%fragment(alaqil_From_frag(Type),"header")
{
alaqilINTERNINLINE PyObject*
alaqil_From(Type)(%ifcplusplus(const Type&, Type) c)
{
  return PyComplex_FromDoubles(Real(c), Imag(c));
}
}
%enddef

/* the double case */
%define %alaqil_cplxdbl_conv(Type, Constructor, Real, Imag)
%fragment(alaqil_AsVal_frag(Type),"header",
	  fragment=alaqil_AsVal_frag(double))
{
alaqilINTERN int
alaqil_AsVal(Type) (PyObject *o, Type* val)
{
  if (PyComplex_Check(o)) {
    if (val) *val = Constructor(PyComplex_RealAsDouble(o), PyComplex_ImagAsDouble(o));
    return alaqil_OK;
  } else {
    double d;    
    int res = alaqil_AddCast(alaqil_AsVal(double)(o, &d));
    if (alaqil_IsOK(res)) {
      if (val) *val = Constructor(d, 0.0);
      return res;
    }
  }
  return alaqil_TypeError;
}
}
%alaqil_fromcplx_conv(Type, Real, Imag);
%enddef

/* the float case */
%define %alaqil_cplxflt_conv(Type, Constructor, Real, Imag)
%fragment(alaqil_AsVal_frag(Type),"header",
          fragment=alaqil_AsVal_frag(float)) {
alaqilINTERN int
alaqil_AsVal(Type)(PyObject *o, Type *val)
{
  if (PyComplex_Check(o)) {
    double re = PyComplex_RealAsDouble(o);
    double im = PyComplex_ImagAsDouble(o);
    if ((-FLT_MAX <= re && re <= FLT_MAX) && (-FLT_MAX <= im && im <= FLT_MAX)) {
      if (val) *val = Constructor(%numeric_cast(re, float),
				  %numeric_cast(im, float));
      return alaqil_OK;
    } else {
      return alaqil_OverflowError;
    }    
  } else {
    float re;
    int res = alaqil_AddCast(alaqil_AsVal(float)(o, &re));
    if (alaqil_IsOK(res)) {
      if (val) *val = Constructor(re, 0.0);
      return res;
    }
  }
  return alaqil_TypeError;
}
}

%alaqil_fromcplx_conv(Type, Real, Imag);
%enddef

#define %alaqil_cplxflt_convn(Type, Constructor, Real, Imag) \
%alaqil_cplxflt_conv(Type, Constructor, Real, Imag)


#define %alaqil_cplxdbl_convn(Type, Constructor, Real, Imag) \
%alaqil_cplxdbl_conv(Type, Constructor, Real, Imag)


