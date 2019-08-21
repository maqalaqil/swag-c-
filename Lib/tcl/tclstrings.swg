/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */

%fragment("alaqil_AsCharPtrAndSize","header") {
alaqilINTERN int
alaqil_AsCharPtrAndSize(Tcl_Obj *obj, char** cptr, size_t* psize, int *alloc)
{ 
  int len = 0;
  char *cstr = Tcl_GetStringFromObj(obj, &len);
  if (cstr) {
    if (cptr)  *cptr = cstr;
    if (psize) *psize = len + 1;
    if (alloc) *alloc = alaqil_OLDOBJ;
    return alaqil_OK;
  }
  return alaqil_TypeError;
}
}


%fragment("alaqil_FromCharPtrAndSize","header",
	  fragment="<limits.h>") {
alaqilINTERNINLINE Tcl_Obj *
alaqil_FromCharPtrAndSize(const char* carray, size_t size)
{
  return (size < INT_MAX) ? Tcl_NewStringObj(carray, %numeric_cast(size,int)) : NULL;
}
}


