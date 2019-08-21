/*
  Defines the As/From conversors for double/float complex, you need to
  provide complex Type, the Name you want to use in the converters,
  the complex Constructor method, and the Real and Imag complex
  accessor methods.

  See the std_complex.i and ccomplex.i for concrete examples.
*/

%fragment("rb_complex_new","header")
{
%#if !defined(T_COMPLEX)
/* Ruby versions prior to 1.9 did not have native complex numbers.  They were an extension in the STD library.  */
alaqilINTERN VALUE rb_complex_new(VALUE x, VALUE y) {
  static ID new_id = rb_intern("new");
  static VALUE cComplex = rb_const_get(rb_cObject, rb_intern("Complex"));
  return rb_funcall(cComplex, new_id, 2, x, y);
}
%#endif
}

%fragment("alaqil_Complex_Numbers","header")
{
%#if !defined(T_COMPLEX)
alaqilINTERN int alaqil_Is_Complex( VALUE obj ) {
  static ID real_id = rb_intern("real");
  static ID imag_id = rb_intern("imag");
  return ( (rb_respond_to( obj, real_id ) ) &&
           (rb_respond_to( obj, imag_id ) ) );
}
%#else
alaqilINTERN int alaqil_Is_Complex( VALUE obj ) {
  return TYPE(obj) == T_COMPLEX;
}
%#endif

alaqilINTERN VALUE alaqil_Complex_Real(VALUE obj) {
  static ID real_id = rb_intern("real");
  return rb_funcall(obj, real_id, 0);
}

alaqilINTERN VALUE alaqil_Complex_Imaginary(VALUE obj) {
  static ID imag_id = rb_intern("imag");
  return rb_funcall(obj, imag_id, 0);
}
}

%init {
%#if !defined(T_COMPLEX)
  rb_require("complex");
%#endif
}

/* the common from converter */
%define %alaqil_fromcplx_conv(Type, Real, Imag)
%fragment(alaqil_From_frag(Type),"header",fragment="rb_complex_new")
{
alaqilINTERNINLINE VALUE
alaqil_From(Type)(%ifcplusplus(const Type&, Type) c)
{
  VALUE re = rb_float_new(Real(c));
  VALUE im = rb_float_new(Imag(c));
  return rb_complex_new(re, im);
}
}
%enddef

/* the double case */
%define %alaqil_cplxdbl_conv(Type, Constructor, Real, Imag)
%fragment(alaqil_AsVal_frag(Type),"header",
	  fragment=alaqil_AsVal_frag(double),
          fragment="alaqil_Complex_Numbers")
{
alaqilINTERN int
alaqil_AsVal(Type) (VALUE o, Type* val)
{
  if ( alaqil_Is_Complex( o ) ) {
    if (val) {
      VALUE real = alaqil_Complex_Real(o);
      VALUE imag = alaqil_Complex_Imaginary(o);
      double re = 0;
      alaqil_AsVal_double( real, &re );
      double im = 0;
      alaqil_AsVal_double( imag, &im );
      *val = Constructor(re, im);
    }
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
          fragment=alaqil_AsVal_frag(float),
          fragment=alaqil_AsVal_frag(double),
          fragment="alaqil_Complex_Numbers") {
alaqilINTERN int
alaqil_AsVal(Type)(VALUE o, Type *val)
{
  if ( alaqil_Is_Complex( o ) ) {
    VALUE real = alaqil_Complex_Real(o);
    VALUE imag = alaqil_Complex_Imaginary(o);
    double re = 0;
    alaqil_AsVal_double( real, &re );
    double im = 0;
    alaqil_AsVal_double( imag, &im );
    if ((-FLT_MAX <= re && re <= FLT_MAX) && 
	(-FLT_MAX <= im && im <= FLT_MAX)) {
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


