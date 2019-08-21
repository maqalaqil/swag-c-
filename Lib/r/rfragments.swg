#define alaqil_Error(code, msg) Rf_warning(msg); return Rf_ScalarLogical(NA_LOGICAL)

#define alaqil_fail return Rf_ScalarLogical(NA_LOGICAL)

/* for raw pointers */
#define alaqil_ConvertPtr(oc, ptr, ty, flags)             alaqil_R_ConvertPtr(oc, ptr, ty, flags)
#define alaqil_ConvertFunctionPtr(oc, ptr, ty)            alaqil_R_ConvertPtr(oc, ptr, ty, 0)
#define alaqil_NewPointerObj(ptr, ty, flags)              alaqil_R_NewPointerObj(ptr, ty, flags)
#define alaqil_NewFunctionPtrObj(ptr, ty)                 alaqil_R_NewPointerObj(ptr, ty, 0)

/* for raw packed data */
#define alaqil_ConvertPacked(obj, ptr, sz, ty)            alaqil_R_ConvertPacked(obj, ptr, sz, ty)
#define alaqil_NewPackedObj(ptr, sz, ty)                  alaqil_R_NewPackedObj(ptr, sz, ty)

/* for class or struct pointers */
#define alaqil_ConvertInstance(obj, pptr, ty, flags)      alaqil_ConvertPtr(obj, pptr, ty, flags)
#define alaqil_NewInstanceObj(ptr, ty, flags)             alaqil_NewPointerObj(ptr, ty, flags)

/* for C++ member pointers, ie, member methods */
#define alaqil_ConvertMember(obj, ptr, sz, ty)            alaqil_R_ConvertPacked(obj, ptr, sz, ty)
#define alaqil_NewMemberObj(ptr, sz, ty)                  alaqil_R_NewPackedObj(ptr, sz, ty)


/* Runtime API */

#define alaqil_GetModule(clientdata)                      alaqil_R_GetModule()
#define alaqil_SetModule(clientdata, pointer)             alaqil_R_SetModule(pointer)

%fragment(alaqil_From_frag(long),"header") {
alaqilINTERNINLINE SEXP
alaqil_From_dec(long)(long value)
{
	return Rf_ScalarInteger((int)value);
}
}

%fragment(alaqil_AsVal_frag(long),"header") {
alaqilINTERNINLINE  int
alaqil_AsVal_dec(long)(SEXP obj, long *val)
{
   if (val) *val = Rf_asInteger(obj);
   return alaqil_OK;
}
}


%fragment(alaqil_From_frag(long long),"header",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERNINLINE SEXP
alaqil_From_dec(long long)(long long value)
{
	return Rf_ScalarInteger((int)value);
}
%#endif
}

%fragment(alaqil_AsVal_frag(long long),"header",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERNINLINE  int
alaqil_AsVal_dec(long long)(SEXP obj, long long *val)
{
   if (val) *val = Rf_asInteger(obj);
   return alaqil_OK;
}
%#endif
}

%fragment(alaqil_From_frag(unsigned long),"header") {
alaqilINTERNINLINE SEXP
alaqil_From_dec(unsigned long)(unsigned long value)
{
	return Rf_ScalarInteger((int)value);
}
}


%fragment(alaqil_AsVal_frag(unsigned long),"header") {
alaqilINTERNINLINE  int
alaqil_AsVal_dec(unsigned long)(SEXP obj, unsigned long *val)
{
   if (val) *val = Rf_asInteger(obj);
   return alaqil_OK;
}
}


%fragment(alaqil_From_frag(unsigned long long),"header",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERNINLINE SEXP
alaqil_From_dec(unsigned long long)(unsigned long long value)
{
	return Rf_ScalarInteger((int)value);
}
%#endif
}


%fragment(alaqil_AsVal_frag(unsigned long long),"header",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERNINLINE  int
alaqil_AsVal_dec(unsigned long long)(SEXP obj, unsigned long long *val)
{
   if (val) *val = Rf_asInteger(obj);
   return alaqil_OK;
}
%#endif
}

%fragment(alaqil_From_frag(double),"header") {
alaqilINTERNINLINE SEXP
alaqil_From_dec(double)(double value)
{
	return Rf_ScalarReal(value);
}
}


%fragment(alaqil_AsVal_frag(double),"header") {
alaqilINTERNINLINE  int
alaqil_AsVal_dec(double)(SEXP obj, double *val)
{
   if (val) *val = Rf_asReal(obj);
   return alaqil_OK;
}
}

%fragment("alaqil_AsCharPtrAndSize", "header") 
{
alaqilINTERN int
alaqil_AsCharPtrAndSize(SEXP obj, char** cptr, size_t* psize, int *alloc)
{
  if (cptr && Rf_isString(obj)) {
    char *cstr = %const_cast(CHAR(STRING_ELT(obj, 0)), char *);
    int len = strlen(cstr);

    if (alloc) {
      if (*alloc == alaqil_NEWOBJ) {
        *cptr = %new_copy_array(cstr, len + 1, char);
        *alloc = alaqil_NEWOBJ;
      } else {
        *cptr = cstr;
      }
    } else {
      *cptr = %reinterpret_cast(malloc(len + 1), char *);
      *cptr = strcpy(*cptr, cstr);
    }
    if (psize) *psize = len + 1;
    return alaqil_OK;
  }
  return alaqil_TypeError;
}
}

%fragment("alaqil_strdup","header") 
{
alaqilINTERN char *
alaqil_strdup(const char *str)
{
  char *newstr = %reinterpret_cast(malloc(strlen(str) + 1), char *);
  return strcpy(newstr, str);
}
}

//# This is modified from the R header files

%fragment("alaqil_FromCharPtrAndSize","header") 
{
alaqilINTERN SEXP
alaqil_FromCharPtrAndSize(const char* carray, size_t size) 
{
  SEXP t, c;
  if (!carray) return R_NilValue;
/* See R internals document 1.10.  
   MkCharLen was introduced in 2.7.0.  Use that instead of hand
   creating vector.

   Starting in 2.8.0 creating strings via vectors was deprecated in
   order to allow for use of CHARSXP caches. */

  Rf_protect(t = Rf_allocVector(STRSXP, 1));
%#if R_VERSION >=  R_Version(2,7,0)
  c = Rf_mkCharLen(carray, size);
%#else
  c = Rf_allocVector(CHARSXP, size);
  strncpy((char *)CHAR(c), carray, size);
%#endif
  SET_STRING_ELT(t, 0, c);
  Rf_unprotect(1);
  return t;
}
}
