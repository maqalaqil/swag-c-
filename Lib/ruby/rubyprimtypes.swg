/* -----------------------------------------------------------------------------
 * rubyprimtypes.swg
 * ----------------------------------------------------------------------------- */
/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* auxiliary ruby fail method */

%fragment("alaqil_ruby_failed","header")
{
alaqilINTERN VALUE
alaqil_ruby_failed(void)
{
  return Qnil;
} 
}

%define %ruby_aux_method(Type, Method, Action)
alaqilINTERN VALUE alaqil_AUX_##Method##(VALUE *args)
{
  VALUE obj = args[0];
  VALUE type = TYPE(obj);
  Type *res = (Type *)(args[1]);
  *res = Action;
  return obj;
}
%enddef


/* boolean */

%fragment(alaqil_From_frag(bool),"header") {
alaqilINTERNINLINE VALUE
alaqil_From_dec(bool)(bool value)
{
  return value ? Qtrue : Qfalse;
}
}

%fragment(alaqil_AsVal_frag(bool),"header",
	  fragment=alaqil_AsVal_frag(int)) {
alaqilINTERN int
alaqil_AsVal_dec(bool)(VALUE obj, bool *val)
{
  if (obj == Qtrue) {
    if (val) *val = true;
    return alaqil_OK;
  } else if (obj == Qfalse) {
    if (val) *val = false;
    return alaqil_OK;
  } else {
    int res = 0;
    if (alaqil_AsVal(int)(obj, &res) == alaqil_OK) {    
      if (val) *val = res ? true : false;
      return alaqil_OK;
    }
  }  
  return alaqil_TypeError;
}
}

/* long */

%fragment(alaqil_From_frag(long),"header",
	  fragment="<limits.h>") {
  %define_as(alaqil_From_dec(long),           LONG2NUM)
}

%fragment(alaqil_AsVal_frag(long),"header",fragment="alaqil_ruby_failed") {
%ruby_aux_method(long, NUM2LONG, type == T_FIXNUM ? NUM2LONG(obj) : rb_big2long(obj))

alaqilINTERN int
alaqil_AsVal_dec(long)(VALUE obj, long* val)
{
  VALUE type = TYPE(obj);
  if ((type == T_FIXNUM) || (type == T_BIGNUM)) {
    long v;
    VALUE a[2];
    a[0] = obj;
    a[1] = (VALUE)(&v);
    if (rb_rescue(RUBY_METHOD_FUNC(alaqil_AUX_NUM2LONG), (VALUE)a, RUBY_METHOD_FUNC(alaqil_ruby_failed), 0) != Qnil) {
      if (val) *val = v;
      return alaqil_OK;
    }
  }
  return alaqil_TypeError;
}
}

/* unsigned long */

%fragment(alaqil_From_frag(unsigned long),"header",
	  fragment=alaqil_From_frag(long)) {
alaqilINTERNINLINE VALUE
alaqil_From_dec(unsigned long)(unsigned long value)
{
  return ULONG2NUM(value); 
}
}

%fragment(alaqil_AsVal_frag(unsigned long),"header",fragment="alaqil_ruby_failed") {
%ruby_aux_method(unsigned long, NUM2ULONG, type == T_FIXNUM ? NUM2ULONG(obj) : rb_big2ulong(obj))

alaqilINTERN int
alaqil_AsVal_dec(unsigned long)(VALUE obj, unsigned long *val) 
{
  VALUE type = TYPE(obj);
  if ((type == T_FIXNUM) || (type == T_BIGNUM)) {
    unsigned long v;
    VALUE a[2];
    a[0] = obj;
    a[1] = (VALUE)(&v);
    if (rb_rescue(RUBY_METHOD_FUNC(alaqil_AUX_NUM2ULONG), (VALUE)a, RUBY_METHOD_FUNC(alaqil_ruby_failed), 0) != Qnil) {
      if (val) *val = v;
      return alaqil_OK;
    }
  }
  return alaqil_TypeError;
}
}

/* long long */

%fragment(alaqil_From_frag(long long),"header",
	  fragment=alaqil_From_frag(long),
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERNINLINE VALUE 
alaqil_From_dec(long long)(long long value)
{
  return LL2NUM(value);
}
%#endif
}

%fragment(alaqil_AsVal_frag(long long),"header",
	  fragment="alaqil_ruby_failed",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
%ruby_aux_method(long long, NUM2LL, type == T_FIXNUM ? NUM2LL(obj) : rb_big2ll(obj))

alaqilINTERN int
alaqil_AsVal_dec(long long)(VALUE obj, long long *val)
{
  VALUE type = TYPE(obj);
  if ((type == T_FIXNUM) || (type == T_BIGNUM)) {
    long long v;
    VALUE a[2];
    a[0] = obj;
    a[1] = (VALUE)(&v);
    if (rb_rescue(RUBY_METHOD_FUNC(alaqil_AUX_NUM2LL), (VALUE)a, RUBY_METHOD_FUNC(alaqil_ruby_failed), 0) != Qnil) {
      if (val) *val = v;
      return alaqil_OK;
    }
  }
  return alaqil_TypeError;
}
%#endif
}

/* unsigned long long */

%fragment(alaqil_From_frag(unsigned long long),"header",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERNINLINE VALUE 
alaqil_From_dec(unsigned long long)(unsigned long long value)
{
  return ULL2NUM(value);
}
%#endif
}

%fragment(alaqil_AsVal_frag(unsigned long long),"header",
	  fragment="alaqil_ruby_failed",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
%ruby_aux_method(long long, NUM2ULL,  type == T_FIXNUM ? NUM2ULL(obj) : rb_big2ull(obj))

alaqilINTERN int
alaqil_AsVal_dec(unsigned long long)(VALUE obj, unsigned long long *val)
{ 
  VALUE type = TYPE(obj);
  if ((type == T_FIXNUM) || (type == T_BIGNUM)) {
    unsigned long long v;
    VALUE a[2];
    a[0] = obj;
    a[1] = (VALUE)(&v);
    if (rb_rescue(RUBY_METHOD_FUNC(alaqil_AUX_NUM2ULL), (VALUE)a, RUBY_METHOD_FUNC(alaqil_ruby_failed), 0) != Qnil) {
      if (val) *val = v;
      return alaqil_OK;
    }
  }
  return alaqil_TypeError;
}
%#endif
}

/* double */

%fragment(alaqil_From_frag(double),"header") {
  %define_as(alaqil_From_dec(double),  rb_float_new)
}

%fragment(alaqil_AsVal_frag(double),"header",fragment="alaqil_ruby_failed") {
%ruby_aux_method(double, NUM2DBL, NUM2DBL(obj); (void)type)

alaqilINTERN int
alaqil_AsVal_dec(double)(VALUE obj, double *val)
{
  VALUE type = TYPE(obj);
  if ((type == T_FLOAT) || (type == T_FIXNUM) || (type == T_BIGNUM)) {
    double v;
    VALUE a[2];
    a[0] = obj;
    a[1] = (VALUE)(&v);
    if (rb_rescue(RUBY_METHOD_FUNC(alaqil_AUX_NUM2DBL), (VALUE)a, RUBY_METHOD_FUNC(alaqil_ruby_failed), 0) != Qnil) {
      if (val) *val = v;
      return alaqil_OK;
    }
  }
  return alaqil_TypeError;
}
}


