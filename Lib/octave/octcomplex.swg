/*
  Defines the As/From conversors for double/float complex, you need to
  provide complex Type, the Name you want to use in the conversors,
  the complex Constructor method, and the Real and Imag complex
  accesor methods.

  See the std_complex.i and ccomplex.i for concrete examples.
*/

/* the common from conversor */
%define %alaqil_fromcplx_conv(Type, OctConstructor, Real, Imag)
     %fragment(alaqil_From_frag(Type),"header")
{
  alaqilINTERNINLINE octave_value
    alaqil_From(Type)(const Type& c)
    {
      return octave_value(OctConstructor(Real(c), Imag(c)));
    }
}
%enddef

// the double case
%define %alaqil_cplxdbl_conv(Type, Constructor, Real, Imag)
     %fragment(alaqil_AsVal_frag(Type),"header",
	       fragment=alaqil_AsVal_frag(double))
{
  alaqilINTERN int
    alaqil_AsVal(Type) (const octave_value& ov, Type* val)
    {
      if (ov.is_complex_scalar()) {
	if (val) {
	  Complex c(ov.complex_value());
	  *val=Constructor(c.real(),c.imag());
	}
	return alaqil_OK;
      } else {
	double d;    
	int res = alaqil_AddCast(alaqil_AsVal(double)(ov, &d));
	if (alaqil_IsOK(res)) {
	  if (val)
	    *val = Constructor(d, 0.0);
	  return res;
	}
      }
      return alaqil_TypeError;
    }
}
%alaqil_fromcplx_conv(Type, Complex, Real, Imag);
%enddef

// the float case
%define %alaqil_cplxflt_conv(Type, Constructor, Real, Imag)
     %fragment(alaqil_AsVal_frag(Type),"header",
	       fragment=alaqil_AsVal_frag(float)) {
  alaqilINTERN int
    alaqil_AsVal(Type) (const octave_value& ov, Type* val)
    {
      if (ov.is_complex_scalar()) {
	if (val) {
	  Complex c(ov.complex_value());
	  double re = c.real();
	  double im = c.imag();
	  if ((-FLT_MAX <= re && re <= FLT_MAX) && (-FLT_MAX <= im && im <= FLT_MAX)) {
	    if (val)
	      *val = Constructor(%numeric_cast(re, float),
				 %numeric_cast(im, float));
	    return alaqil_OK;
	  } else
	    return alaqil_OverflowError;
	}
      } else {
	float d;    
	int res = alaqil_AddCast(alaqil_AsVal(float)(ov, &d));
	if (alaqil_IsOK(res)) {
	  if (val)
	    *val = Constructor(d, 0.0);
	  return res;
	}
      }
      return alaqil_TypeError;
    }
}

%alaqil_fromcplx_conv(Type, FloatComplex, Real, Imag);
%enddef

#define %alaqil_cplxflt_convn(Type, Constructor, Real, Imag) \
%alaqil_cplxflt_conv(Type, Constructor, Real, Imag)


#define %alaqil_cplxdbl_convn(Type, Constructor, Real, Imag) \
%alaqil_cplxdbl_conv(Type, Constructor, Real, Imag)
