/*
  Defines the As/From converters for double/float complex, you need to
  provide complex Type, the Name you want to use in the converters,
  the complex Constructor method, and the Real and Imag complex
  accessor methods.

  See the std_complex.i and ccomplex.i for concrete examples.
*/

/* the common from converter */
%define %alaqil_fromcplx_conv(Type, Real, Imag)
%fragment(alaqil_From_frag(Type),"header",
          fragment=alaqil_From_frag(double))
{
alaqilINTERNINLINE JSObjectRef
alaqil_From_dec(Type)(%ifcplusplus(const Type&, Type) c)
{
  JSValueRef vals[2];
  vals[0] =  alaqil_From(double)(Real(c));
  vals[1] =  alaqil_From(double)(Imag(c));
  return JSObjectMakeArray(context, 2, vals, NULL);
}
}
%enddef

/* the double case */
%define %alaqil_cplxdbl_conv(Type, Constructor, Real, Imag)
%fragment(alaqil_AsVal_frag(Type),"header",
	  fragment=alaqil_AsVal_frag(double))
{
alaqilINTERN int
alaqil_AsVal_dec(Type) (JSValueRef o, Type* val)
{
  if (JSValueIsObject(context, o)) {
    JSObjectRef array;
    JSValueRef exception, js_re, js_im;
    double re, im;
    int res;
    
    exception = 0;
    res = 0;

    array = JSValueToObject(context, o, &exception);
    if(exception != 0)
      return alaqil_TypeError;
    
    js_re = JSObjectGetPropertyAtIndex(context, array, 0, &exception);
    if(exception != 0)
      return alaqil_TypeError;

    js_im = JSObjectGetPropertyAtIndex(context, array, 1, &exception);
    if(exception != 0)
      return alaqil_TypeError;

    res = alaqil_AsVal(double)(js_re, &re);
    if(!alaqil_IsOK(res)) {
      return alaqil_TypeError;
    }
    
    res = alaqil_AsVal(double)(js_im, &im);
    if(!alaqil_IsOK(res)) {
      return alaqil_TypeError;
    }
    
    if (val) *val = Constructor(re, im);
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
alaqil_AsVal_dec(Type)(JSValueRef o, Type *val)
{
  if (JSValueIsObject(context, o)) {
    JSObjectRef array;
    JSValueRef exception, js_re, js_im;
    double re, im;
    int res;
    
    exception = 0;
    res = 0;

    array = JSValueToObject(context, o, &exception);
    if(exception != 0)
      return alaqil_TypeError;
    
    js_re = JSObjectGetPropertyAtIndex(context, array, 0, &exception);
    if(exception != 0)
      return alaqil_TypeError;

    js_im = JSObjectGetPropertyAtIndex(context, array, 1, &exception);
    if(exception != 0)
      return alaqil_TypeError;

    res = alaqil_AsVal(double)(js_re, &re);
    if(!alaqil_IsOK(res)) {
      return alaqil_TypeError;
    }
    
    res = alaqil_AsVal(double)(js_im, &im);
    if(!alaqil_IsOK(res)) {
      return alaqil_TypeError;
    }

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
