/* -----------------------------------------------------------------------------
 * cdata.swg
 *
 * This library file contains macros for manipulating raw C data as strings.
 * ----------------------------------------------------------------------------- */

%{
typedef struct alaqilCDATA {
    char *data;
    size_t   len;
} alaqilCDATA;
%}

/* -----------------------------------------------------------------------------
 * Typemaps for returning binary data
 * ----------------------------------------------------------------------------- */

%typemap(out,noblock=1,fragment="alaqil_FromCharPtrAndSize") alaqilCDATA {
  %set_output(alaqil_FromCharPtrAndSize($1.data,$1.len));
}
%typemap(in) (const void *indata, size_t inlen) = (char *STRING, size_t SIZE);


/* -----------------------------------------------------------------------------
 * %cdata(TYPE [, NAME]) 
 *
 * Convert raw C data to a binary string.
 * ----------------------------------------------------------------------------- */

%define %cdata(TYPE,NAME...)

%insert("header") {
#ifdef __cplusplus
extern "C"  {    
#endif
#if #NAME == ""
static alaqilCDATA cdata_##TYPE(TYPE *ptr, size_t nelements)
#else
static alaqilCDATA cdata_##NAME(TYPE *ptr, size_t nelements)
#endif
{
  alaqilCDATA d;
  d.data = (char *) ptr;
#if #TYPE != "void"
  d.len  = nelements*sizeof(TYPE);
#else
  d.len  = nelements;
#endif
   return d;
}
#ifdef __cplusplus
}
#endif 
}

#ifdef __cplusplus
extern "C"
#endif
#if #NAME == ""
alaqilCDATA cdata_##TYPE(TYPE *ptr, size_t nelements = 1);
#else
alaqilCDATA cdata_##NAME(TYPE *ptr, size_t nelements = 1);
#endif
%enddef

%rename(cdata) ::cdata_void(void *ptr, size_t nelements = 1);

%cdata(void);

/* Memory move function. Due to multi-argument typemaps this appears to be wrapped as
void memmove(void *data, const char *s); */
void memmove(void *data, const void *indata, size_t inlen);




