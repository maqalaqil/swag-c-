/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(alaqil_From_frag(bool),"header") {
alaqilINTERNINLINE
JSValueRef alaqil_From_dec(bool)(bool value)
{
  return JSValueMakeBoolean(context, value);
}
}

%fragment(alaqil_AsVal_frag(bool),"header",
          fragment=alaqil_AsVal_frag(long)) {
alaqilINTERN
int alaqil_AsVal_dec(bool)(JSValueRef obj, bool *val)
{
  if(!JSValueIsBoolean(context, obj)) {
    return alaqil_ERROR;
  }
  if (val) *val = JSValueToBoolean(context, obj);
  return alaqil_OK;
}
}

/* int */

%fragment(alaqil_From_frag(int),"header") {
alaqilINTERNINLINE JSValueRef
  alaqil_From_dec(int)(int value)
{
  return JSValueMakeNumber(context, value);
}
}

/* long */

%fragment(alaqil_From_frag(long),"header") {
alaqilINTERNINLINE JSValueRef
alaqil_From_dec(long)(long value)
{
  return JSValueMakeNumber(context, value);
}
}

%fragment(alaqil_AsVal_frag(long),"header",
          fragment="alaqil_CanCastAsInteger") {
alaqilINTERN int
alaqil_AsVal_dec(long)(JSValueRef obj, long* val)
{
  if (!JSValueIsNumber(context, obj)) {
    return alaqil_TypeError;
  }
  if(val) *val = (long) JSValueToNumber(context, obj, NULL);

  return alaqil_OK;
}
}

/* unsigned long */

%fragment(alaqil_From_frag(unsigned long),"header",
          fragment=alaqil_From_frag(long)) {
alaqilINTERNINLINE JSValueRef
alaqil_From_dec(unsigned long)(unsigned long value)
{
  return (value > LONG_MAX) ?
    JSValueMakeNumber(context, value) : JSValueMakeNumber(context, %numeric_cast(value,long));
}
}

%fragment(alaqil_AsVal_frag(unsigned long),"header",
          fragment="alaqil_CanCastAsInteger") {
alaqilINTERN int
alaqil_AsVal_dec(unsigned long)(JSValueRef obj, unsigned long *val)
{
  long longVal;
  if(!JSValueIsNumber(context, obj)) {
    return alaqil_TypeError;
  }

  longVal = (long) JSValueToNumber(context, obj, NULL);

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
alaqilINTERNINLINE JSValueRef
alaqil_From_dec(long long)(long long value)
{
  return JSValueMakeNumber(context, value);
}
%#endif
}

%fragment(alaqil_AsVal_frag(long long),"header",
    fragment=alaqil_AsVal_frag(long),
    fragment="alaqil_CanCastAsInteger",
    fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERN int
alaqil_AsVal_dec(long long)(JSValueRef obj, long long* val)
{
  if (!JSValueIsNumber(context, obj)) {
    return alaqil_TypeError;
  }
  if(val) *val = (long long) JSValueToNumber(context, obj, NULL);

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
alaqilINTERN JSValueRef
alaqil_From_dec(unsigned long long)(unsigned long long value)
{
  return (value > LONG_MAX) ?
    JSValueMakeNumber(context, value) : JSValueMakeNumber(context, %numeric_cast(value,long));
}
%#endif
}

%fragment(alaqil_AsVal_frag(unsigned long long),"header",
    fragment=alaqil_AsVal_frag(unsigned long),
    fragment="alaqil_CanCastAsInteger",
   fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERN int
alaqil_AsVal_dec(unsigned long long)(JSValueRef obj, unsigned long long *val)
{
  long long longVal;
  if(!JSValueIsNumber(context, obj)) {
    return alaqil_TypeError;
  }

  longVal = (unsigned long long) JSValueToNumber(context, obj, NULL);

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
alaqilINTERN JSValueRef
alaqil_From_dec(double) (double val)
{
  return JSValueMakeNumber(context, val);
}
}

%fragment(alaqil_AsVal_frag(double),"header") {
alaqilINTERN int
alaqil_AsVal_dec(double)(JSValueRef obj, double *val)
{
  if(!JSValueIsNumber(context, obj)) {
    return alaqil_TypeError;
  }
  if(val) *val = JSValueToNumber(context, obj, NULL);

  return alaqil_OK;
}
}
