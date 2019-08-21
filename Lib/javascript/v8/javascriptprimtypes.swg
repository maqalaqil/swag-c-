/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(alaqil_From_frag(bool),"header") {
alaqilINTERNINLINE
v8::Handle<v8::Value>
alaqil_From_dec(bool)(bool value)
{
  return alaqilV8_BOOLEAN_NEW(value);
}
}

%fragment(alaqil_AsVal_frag(bool),"header",
          fragment=alaqil_AsVal_frag(long)) {
alaqilINTERN
int alaqil_AsVal_dec(bool)(v8::Handle<v8::Value> obj, bool *val)
{
  if(!obj->IsBoolean()) {
    return alaqil_ERROR;
  }

  if (val) *val = alaqilV8_BOOLEAN_VALUE(obj);
  return alaqil_OK;
}
}

/* int */

%fragment(alaqil_From_frag(int),"header") {
alaqilINTERNINLINE
v8::Handle<v8::Value> alaqil_From_dec(int)(int value)
{
  return alaqilV8_INT32_NEW(value);
}
}

%fragment(alaqil_AsVal_frag(int),"header") {
alaqilINTERN
int alaqil_AsVal_dec(int)(v8::Handle<v8::Value> valRef, int* val)
{
  if (!valRef->IsNumber()) {
    return alaqil_TypeError;
  }
  if(val) *val = alaqilV8_INTEGER_VALUE(valRef);

  return alaqil_OK;
}
}

/* long */

%fragment(alaqil_From_frag(long),"header") {
alaqilINTERNINLINE
v8::Handle<v8::Value> alaqil_From_dec(long)(long value)
{
  return alaqilV8_NUMBER_NEW(value);
}
}

%fragment(alaqil_AsVal_frag(long),"header",
          fragment="alaqil_CanCastAsInteger") {
alaqilINTERN
int alaqil_AsVal_dec(long)(v8::Handle<v8::Value> obj, long* val)
{
  if (!obj->IsNumber()) {
    return alaqil_TypeError;
  }
  if(val) *val = (long) alaqilV8_INTEGER_VALUE(obj);

  return alaqil_OK;
}
}

/* unsigned long */

%fragment(alaqil_From_frag(unsigned long),"header",
          fragment=alaqil_From_frag(long)) {
alaqilINTERNINLINE
v8::Handle<v8::Value> alaqil_From_dec(unsigned long)(unsigned long value)
{
  return (value > LONG_MAX) ?
    alaqilV8_INTEGER_NEW_UNS(value) : alaqilV8_INTEGER_NEW(%numeric_cast(value,long));
}
}

%fragment(alaqil_AsVal_frag(unsigned long),"header",
          fragment="alaqil_CanCastAsInteger") {
alaqilINTERN
int alaqil_AsVal_dec(unsigned long)(v8::Handle<v8::Value> obj, unsigned long *val)
{
  if(!obj->IsNumber()) {
    return alaqil_TypeError;
  }

  long longVal = (long) alaqilV8_NUMBER_VALUE(obj);

  if(longVal < 0) {
      return alaqil_OverflowError;
  }

  if(val) *val = longVal;

  return alaqil_OK;
}
}

/* long long */
// Note: these are copied from 'long' and probably need fixing

%fragment(alaqil_From_frag(long long),"header",
    fragment=alaqil_From_frag(long),
    fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERNINLINE
v8::Handle<v8::Value> alaqil_From_dec(long long)(long long value)
{
  return alaqilV8_NUMBER_NEW(value);
}
%#endif
}

%fragment(alaqil_AsVal_frag(long long),"header",
    fragment=alaqil_AsVal_frag(long),
    fragment="alaqil_CanCastAsInteger",
    fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERN
int alaqil_AsVal_dec(long long)(v8::Handle<v8::Value> obj, long long* val)
{
  if (!obj->IsNumber()) {
    return alaqil_TypeError;
  }
  if(val) *val = (long long) alaqilV8_INTEGER_VALUE(obj);

  return alaqil_OK;
}
%#endif
}

/* unsigned long long */
// Note: these are copied from 'unsigned long' and probably need fixing

%fragment(alaqil_From_frag(unsigned long long),"header",
    fragment=alaqil_From_frag(long long),
    fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERNINLINE
v8::Handle<v8::Value> alaqil_From_dec(unsigned long long)(unsigned long long value)
{
  return (value > LONG_MAX) ?
    alaqilV8_INTEGER_NEW_UNS(value) : alaqilV8_INTEGER_NEW(%numeric_cast(value,long));
}
%#endif
}

%fragment(alaqil_AsVal_frag(unsigned long long),"header",
    fragment=alaqil_AsVal_frag(unsigned long),
    fragment="alaqil_CanCastAsInteger",
    fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERN
int alaqil_AsVal_dec(unsigned long long)(v8::Handle<v8::Value> obj, unsigned long long *val)
{
  if(!obj->IsNumber()) {
    return alaqil_TypeError;
  }

  long long longVal = (long long) alaqilV8_NUMBER_VALUE(obj);

  if(longVal < 0) {
      return alaqil_OverflowError;
  }

  if(val) *val = longVal;

  return alaqil_OK;
}
%#endif
}

/* double */

%fragment(alaqil_From_frag(double),"header") {
alaqilINTERN
v8::Handle<v8::Value> alaqil_From_dec(double) (double val)
{
  return alaqilV8_NUMBER_NEW(val);
}
}

%fragment(alaqil_AsVal_frag(double),"header") {
alaqilINTERN
int alaqil_AsVal_dec(double)(v8::Handle<v8::Value> obj, double *val)
{
  if(!obj->IsNumber()) {
    return alaqil_TypeError;
  }
  if(val) *val = alaqilV8_NUMBER_VALUE(obj);

  return alaqil_OK;
}
}

