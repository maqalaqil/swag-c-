/* -----------------------------------------------------------------------------
 * cdata.i
 *
 * alaqil library file containing macros for manipulating raw C data as strings.
 * ----------------------------------------------------------------------------- */

%{
typedef struct alaqilCDATA {
    char *data;
    intgo len;
} alaqilCDATA;
%}

%fragment("cdata", "header") %{
struct alaqilcdata {
  intgo size;
  void *data;
};
%}

%typemap(gotype) alaqilCDATA "[]byte"

%typemap(imtype) alaqilCDATA "uint64"

%typemap(out, fragment="cdata") alaqilCDATA(struct alaqilcdata *alaqil_out) %{
  alaqil_out = (struct alaqilcdata *)malloc(sizeof(*alaqil_out));
  if (alaqil_out) {
    alaqil_out->size = $1.len;
    alaqil_out->data = malloc(alaqil_out->size);
    if (alaqil_out->data) {
      memcpy(alaqil_out->data, $1.data, alaqil_out->size);
    }
  }
  $result = *(long long *)(void **)&alaqil_out;
%}

%typemap(goout) alaqilCDATA %{
  {
    type alaqilcdata struct { size int; data uintptr }
    p := (*alaqilcdata)(unsafe.Pointer(uintptr($1)))
    if p == nil || p.data == 0 {
      $result = nil
    } else {
      b := make([]byte, p.size)
      a := (*[0x7fffffff]byte)(unsafe.Pointer(p.data))[:p.size]
      copy(b, a)
      alaqil_free(p.data)
      alaqil_free(uintptr(unsafe.Pointer(p)))
      $result = b
    }
  }
%}

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

/* Memory move function. Due to multi-argument typemaps this appears
   to be wrapped as
   void memmove(void *data, const char *s); */
void memmove(void *data, char *indata, int inlen);
