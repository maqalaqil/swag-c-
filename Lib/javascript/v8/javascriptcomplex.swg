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
alaqilINTERNINLINE v8::Handle<v8::Value>
alaqil_From_dec(Type)(%ifcplusplus(const Type&, Type) c)
{
  alaqilV8_HANDLESCOPE_ESC();

  v8::Local<v8::Array> vals = alaqilV8_ARRAY_NEW();

  vals->Set(0, alaqil_From(double)(Real(c)));
  vals->Set(1, alaqil_From(double)(Imag(c)));
  alaqilV8_ESCAPE(vals);
}
}
%enddef

/* the double case */
%define %alaqil_cplxdbl_conv(Type, Constructor, Real, Imag)
%fragment(alaqil_AsVal_frag(Type),"header",
	  fragment=alaqil_AsVal_frag(double))
{
alaqilINTERN int
alaqil_AsVal_dec(Type) (v8::Handle<v8::Value> o, Type* val)
{
  alaqilV8_HANDLESCOPE();
  
  if (o->IsArray()) {
    v8::Handle<v8::Array> array = v8::Handle<v8::Array>::Cast(o);
    
    if(array->Length() != 2) alaqil_Error(alaqil_TypeError, "Illegal argument for complex: must be array[2].");
    double re, im;
    int res;

    res = alaqil_AsVal(double)(array->Get(0), &re);
    if(!alaqil_IsOK(res)) {
      return alaqil_TypeError;
    }
    
    res = alaqil_AsVal(double)(array->Get(1), &im);
    if(!alaqil_IsOK(res)) {
      return alaqil_TypeError;
    }
    
    if (val) *val = Constructor(re, im);
    return alaqil_OK;
  } else if(o->IsNumber()){
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
alaqil_AsVal_dec(Type) (v8::Handle<v8::Value> o, Type* val)
{
  alaqilV8_HANDLESCOPE();

  if (o->IsArray()) {
    v8::Handle<v8::Array> array = v8::Handle<v8::Array>::Cast(o);
    
    if(array->Length() != 2) alaqil_Error(alaqil_TypeError, "Illegal argument for complex: must be array[2].");
    double re, im;
    int res;

    res = alaqil_AsVal(double)(array->Get(0), &re);
    if(!alaqil_IsOK(res)) {
      return alaqil_TypeError;
    }
    
    res = alaqil_AsVal(double)(array->Get(1), &im);
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
  } else if(o->IsNumber()){
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
