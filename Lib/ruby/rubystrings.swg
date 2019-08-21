/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */

%fragment("alaqil_AsCharPtrAndSize","header",fragment="alaqil_pchar_descriptor") {
alaqilINTERN int
alaqil_AsCharPtrAndSize(VALUE obj, char** cptr, size_t* psize, int *alloc)
{
  if (TYPE(obj) == T_STRING) {
    char *cstr = StringValuePtr(obj); 
    size_t size = RSTRING_LEN(obj) + 1;
    if (cptr)  {
      if (alloc) {
	if (*alloc == alaqil_NEWOBJ) {
	  *cptr = %new_copy_array(cstr, size, char);
	} else {
	  *cptr = cstr;
	  *alloc = alaqil_OLDOBJ;
	}
      }
    }
    if (psize) *psize = size;
    return alaqil_OK;
  } else {
    alaqil_type_info* pchar_descriptor = alaqil_pchar_descriptor();
    if (pchar_descriptor) {
      void* vptr = 0;
      if (alaqil_ConvertPtr(obj, &vptr, pchar_descriptor, 0) == alaqil_OK) {
	if (cptr) *cptr = (char *)vptr;
	if (psize) *psize = vptr ? (strlen((char*)vptr) + 1) : 0;
	if (alloc) *alloc = alaqil_OLDOBJ;
	return alaqil_OK;
      }
    }
  }  
  return alaqil_TypeError;
}
}

%fragment("alaqil_FromCharPtrAndSize","header",fragment="alaqil_pchar_descriptor") {
alaqilINTERNINLINE VALUE 
alaqil_FromCharPtrAndSize(const char* carray, size_t size)
{
  if (carray) {
    if (size > LONG_MAX) {
      alaqil_type_info* pchar_descriptor = alaqil_pchar_descriptor();
      return pchar_descriptor ? 
	alaqil_NewPointerObj(%const_cast(carray,char *), pchar_descriptor, 0) : Qnil;
    } else {
      return rb_str_new(carray, %numeric_cast(size,long));
    }
  } else {
    return Qnil;
  }
}
}

