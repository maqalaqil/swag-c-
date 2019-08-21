/* -----------------------------------------------------------------------------
 * dmemberfunctionpointers.swg
 *
 * Typemaps for member function pointers.
 * ----------------------------------------------------------------------------- */


%typemap(ctype) alaqilTYPE (CLASS::*) "char *"
%typemap(imtype) alaqilTYPE (CLASS::*) "char*"
%typemap(dtype) alaqilTYPE (CLASS::*) "$dclassname"

%typecheck(alaqil_TYPECHECK_POINTER)
  alaqilTYPE (CLASS::*)
  ""


/*
 * Conversion generation typemaps.
 */

%typemap(in, fragment="alaqil_UnPackData") alaqilTYPE (CLASS::*) %{
  alaqil_UnpackData($input, (void *)&$1, sizeof($1));
%}
%typemap(out, fragment="alaqil_PackData") alaqilTYPE (CLASS::*) %{
  char buf[128];
  char *data = alaqil_PackData(buf, (void *)&$1, sizeof($1));
  *data = '\0';
  $result = alaqil_d_string_callback(buf);
%}

%typemap(directorin) alaqilTYPE (CLASS::*) "$input = (void *) $1;"
%typemap(directorout, warning=alaqilWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) alaqilTYPE (CLASS::*)
  "$result = ($1_ltype)$input;"

%typemap(ddirectorin) alaqilTYPE (CLASS::*)
  "($winput is null) ? null : new $dclassname($winput, false)"
%typemap(ddirectorout) alaqilTYPE (CLASS::*) "$dclassname.alaqilGetCPtr($dcall)"

%typemap(din) alaqilTYPE (CLASS::*) "$dclassname.alaqilGetCMemberPtr($dinput)"
%typemap(dout, excode=alaqilEXCODE) alaqilTYPE (CLASS::*) {
  char* cMemberPtr = $imcall;
  $dclassname ret = (cMemberPtr is null) ? null : new $dclassname(cMemberPtr, $owner);$excode
  return ret;
}

%apply alaqilTYPE (CLASS::*) { alaqilTYPE (CLASS::*const) }
%apply alaqilTYPE & { alaqilTYPE (CLASS::*const&) }

/*
 * Helper functions to pack/unpack arbitrary binary data (member function
 * pointers in this case) into a string.
 */

%fragment("alaqil_PackData", "header") {
/* Pack binary data into a string */
alaqilINTERN char * alaqil_PackData(char *c, void *ptr, size_t sz) {
  static const char hex[17] = "0123456789abcdef";
  const unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu =  u + sz;
  for (; u != eu; ++u) {
    unsigned char uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}
}

%fragment("alaqil_UnPackData", "header") {
/* Unpack binary data from a string */
alaqilINTERN const char * alaqil_UnpackData(const char *c, void *ptr, size_t sz) {
  unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu = u + sz;
  for (; u != eu; ++u) {
    char d = *(c++);
    unsigned char uu;
    if ((d >= '0') && (d <= '9'))
      uu = ((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = ((d - ('a'-10)) << 4);
    else
      return (char *) 0;
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (d - ('a'-10));
    else
      return (char *) 0;
    *u = uu;
  }
  return c;
}
}
