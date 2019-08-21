/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * alaqil library file containing macros for manipulating raw C data as strings.
 * ----------------------------------------------------------------------------- */

%{
typedef struct alaqilCDATA {
    char *data;
    int   len;
} alaqilCDATA;
%}

/* -----------------------------------------------------------------------------
 * Typemaps for returning binary data
 * ----------------------------------------------------------------------------- */

#if alaqilGUILE
%typemap(out) alaqilCDATA {
   $result = scm_from_locale_stringn($1.data,$1.len);
}
%typemap(in) (const void *indata, int inlen) = (char *STRING, int LENGTH);

#elif alaqilPHP7

%typemap(out) alaqilCDATA {
  ZVAL_STRINGL($result, $1.data, $1.len);
}
%typemap(in) (const void *indata, int inlen) = (char *STRING, int LENGTH);

#elif alaqilJAVA

%apply (char *STRING, int LENGTH) { (const void *indata, int inlen) }
%typemap(jni) alaqilCDATA "jbyteArray"
%typemap(jtype) alaqilCDATA "byte[]"
%typemap(jstype) alaqilCDATA "byte[]"
%fragment("alaqil_JavaArrayOutCDATA", "header") {
static jbyteArray alaqil_JavaArrayOutCDATA(JNIEnv *jenv, char *result, jsize sz) {
  jbyte *arr;
  int i;
  jbyteArray jresult = JCALL1(NewByteArray, jenv, sz);
  if (!jresult)
    return NULL;
  arr = JCALL2(GetByteArrayElements, jenv, jresult, 0);
  if (!arr)
    return NULL;
  for (i=0; i<sz; i++)
    arr[i] = (jbyte)result[i];
  JCALL3(ReleaseByteArrayElements, jenv, jresult, arr, 0);
  return jresult;
}
}
%typemap(out, fragment="alaqil_JavaArrayOutCDATA") alaqilCDATA
%{$result = alaqil_JavaArrayOutCDATA(jenv, (char *)$1.data, $1.len); %}
%typemap(javaout) alaqilCDATA {
    return $jnicall;
  }

#endif


/* -----------------------------------------------------------------------------
 * %cdata(TYPE [, NAME]) 
 *
 * Convert raw C data to a binary string.
 * ----------------------------------------------------------------------------- */

%define %cdata(TYPE,NAME...)

%insert("header") {
#if #NAME == ""
static alaqilCDATA cdata_##TYPE(TYPE *ptr, int nelements) {
#else
static alaqilCDATA cdata_##NAME(TYPE *ptr, int nelements) {
#endif
   alaqilCDATA d;
   d.data = (char *) ptr;
#if #TYPE != "void"
   d.len  = nelements*sizeof(TYPE);
#else
   d.len  = nelements;
#endif
   return d;
}
}

%typemap(default) int nelements "$1 = 1;"

#if #NAME == ""
alaqilCDATA cdata_##TYPE(TYPE *ptr, int nelements);
#else
alaqilCDATA cdata_##NAME(TYPE *ptr, int nelements);
#endif
%enddef

%typemap(default) int nelements;

%rename(cdata) ::cdata_void(void *ptr, int nelements);

%cdata(void);

/* Memory move function. Due to multi-argument typemaps this appears to be wrapped as
void memmove(void *data, const char *s); */
void memmove(void *data, const void *indata, int inlen);
