/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(alaqil_From_frag(bool),"header") {
  %define_as(alaqil_From_dec(bool),           Tcl_NewBooleanObj)
}

%fragment(alaqil_AsVal_frag(bool),"header") {
alaqilINTERN int
alaqil_AsVal_dec(bool)(Tcl_Obj *obj, bool *val)
{
  int v;
  if (Tcl_GetBooleanFromObj(0, obj, &v) == TCL_OK) {
    if (val) *val = v ? true : false;
    return alaqil_OK;
  }
  return alaqil_TypeError;
}
}

/* long */

%fragment(alaqil_From_frag(long),"header",
	  fragment="<limits.h>") {
alaqilINTERNINLINE Tcl_Obj* 
alaqil_From_dec(long)(long value)
{
  if (((long) INT_MIN <= value) && (value <= (long) INT_MAX)) {
    return Tcl_NewIntObj(%numeric_cast(value,int));
  } else {
    return Tcl_NewLongObj(value);
  }
}
}

%fragment(alaqil_AsVal_frag(long),"header") {
alaqilINTERN int
alaqil_AsVal_dec(long)(Tcl_Obj *obj, long* val)
{
  long v;
  if (Tcl_GetLongFromObj(0,obj, &v) == TCL_OK) {
    if (val) *val = (long) v;
    return alaqil_OK;
  }
  return alaqil_TypeError;
}
}

/* unsigned long */

%fragment(alaqil_From_frag(unsigned long),"header",
	  fragment=alaqil_From_frag(long),
	  fragment="<stdio.h>") {
alaqilINTERNINLINE Tcl_Obj* 
alaqil_From_dec(unsigned long)(unsigned long value)
{
  if (value < (unsigned long) LONG_MAX) {
    return alaqil_From(long)(%numeric_cast(value, long));
  } else {
    char temp[256]; 
    sprintf(temp, "%lu", value);
    return Tcl_NewStringObj(temp,-1);
  }
}
}

%fragment(alaqil_AsVal_frag(unsigned long),"header",
	  fragment="<limits.h>") {
alaqilINTERN int
alaqil_AsVal_dec(unsigned long)(Tcl_Obj *obj, unsigned long *val) {
  long v;
  if (Tcl_GetLongFromObj(0,obj, &v) == TCL_OK) {
    if (v >= 0) {
      if (val) *val = (unsigned long) v;
      return alaqil_OK;
    }
    /* If v is negative, then this could be a negative number, or an
       unsigned value which doesn't fit in a signed long, so try to
       get it as a string so we can distinguish these cases. */
  }
  {
    int len = 0;
    const char *nptr = Tcl_GetStringFromObj(obj, &len);
    if (nptr && len > 0) {
      char *endptr;
      unsigned long v;
      if (*nptr == '-') return alaqil_OverflowError;
      errno = 0;
      v = strtoul(nptr, &endptr,0);
      if (nptr[0] == '\0' || *endptr != '\0')
	return alaqil_TypeError;
      if (v == ULONG_MAX && errno == ERANGE) {
	errno = 0;
	return alaqil_OverflowError;
      } else {
	if (*endptr == '\0') {
	  if (val) *val = v;
	  return alaqil_OK;
	}
      }
    }
  }
  
  return alaqil_TypeError;
}
}

/* long long */

%fragment(alaqil_From_frag(long long),"header",
	  fragment=alaqil_From_frag(long),
	  fragment="alaqil_LongLongAvailable",
	  fragment="<stdio.h>") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERNINLINE Tcl_Obj* 
alaqil_From_dec(long long)(long long value)
{
  if (((long long) LONG_MIN <= value) && (value <= (long long) LONG_MAX)) {
    return alaqil_From(long)(%numeric_cast(value,long));
  } else {    
    char temp[256]; 
    sprintf(temp, "%lld", value);
    return Tcl_NewStringObj(temp,-1);
  }
}
%#endif
}

%fragment(alaqil_AsVal_frag(long long),"header",
	  fragment="alaqil_LongLongAvailable",
	  fragment="<stdlib.h>") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERN int
alaqil_AsVal_dec(long long)(Tcl_Obj *obj, long long *val)
{
  long v;
  if (Tcl_GetLongFromObj(0,obj, &v) == TCL_OK) {
    if (val) *val = v;
    return alaqil_OK;
  } else {
    int len = 0;
    const char *nptr = Tcl_GetStringFromObj(obj, &len);
    if (nptr && len > 0) {
      char *endptr;
      long long v;
      errno = 0;
      v = strtoll(nptr, &endptr,0);
      if (nptr[0] == '\0' || *endptr != '\0')
	return alaqil_TypeError;
      if ((v == LLONG_MAX || v == LLONG_MIN) && errno == ERANGE) {
	errno = 0;
	return alaqil_OverflowError;
      } else {
	if (*endptr == '\0') {
	  if (val) *val = v;
	  return alaqil_OK;
	}
      }
    }
  }
  return alaqil_TypeError;
}
%#endif
}

/* unsigned long long */

%fragment(alaqil_From_frag(unsigned long long),"header",
	  fragment=alaqil_From_frag(long long),
	  fragment="alaqil_LongLongAvailable",
	  fragment="<stdio.h>") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERNINLINE Tcl_Obj* 
alaqil_From_dec(unsigned long long)(unsigned long long value)
{
  if (value < (unsigned long long) LONG_MAX) {
    return alaqil_From(long long)(%numeric_cast(value, long long));
  } else {
    char temp[256]; 
    sprintf(temp, "%llu", value);
    return Tcl_NewStringObj(temp,-1);
  }
}
%#endif
}

%fragment(alaqil_AsVal_frag(unsigned long long),"header",
	  fragment=alaqil_AsVal_frag(unsigned long),
	  fragment="alaqil_LongLongAvailable",
	  fragment="<stdlib.h>") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERN int
alaqil_AsVal_dec(unsigned long long)(Tcl_Obj *obj, unsigned long long *val)
{
  long v;
  if (Tcl_GetLongFromObj(0,obj, &v) == TCL_OK) {
    if (val) *val = (unsigned long) v;
    return alaqil_OK;
  } else {
    int len = 0;
    const char *nptr = Tcl_GetStringFromObj(obj, &len);
    if (nptr && len > 0) {
      char *endptr;
      unsigned long long v;
      if (*nptr == '-') return alaqil_OverflowError;
      errno = 0;
      v = strtoull(nptr, &endptr,0);
      if (nptr[0] == '\0' || *endptr != '\0')
	return alaqil_TypeError;
      if (v == ULLONG_MAX && errno == ERANGE) {
	errno = 0;
	return alaqil_OverflowError;
      } else {
	if (*endptr == '\0') {
	  if (val) *val = v;
	  return alaqil_OK;
	}
      }
    }
  }
  return alaqil_TypeError;
}
%#endif
}

/* double */

%fragment(alaqil_From_frag(double),"header") {
  %define_as(alaqil_From(double),         Tcl_NewDoubleObj)
}

%fragment(alaqil_AsVal_frag(double),"header") {
alaqilINTERN int
alaqil_AsVal_dec(double)(Tcl_Obj *obj, double *val)
{
  double v;
  if (Tcl_GetDoubleFromObj(0, obj, &v) == TCL_OK) {
    if (val) *val = v;
    return alaqil_OK;
  }
  return alaqil_TypeError;
}
}

