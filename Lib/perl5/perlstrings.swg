/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */

%fragment("alaqil_AsCharPtrAndSize","header",fragment="alaqil_pchar_descriptor") {
alaqilINTERN int
alaqil_AsCharPtrAndSize(SV *obj, char** cptr, size_t* psize, int *alloc)
{
  if (SvMAGICAL(obj)) {
     SV *tmp = sv_newmortal();
     SvSetSV(tmp, obj);
     obj = tmp;
  }
  if (SvPOK(obj)) {
    STRLEN len = 0;
    char *cstr = SvPV(obj, len); 
    size_t size = len + 1;
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
      char* vptr = 0; 
      if (alaqil_ConvertPtr(obj, (void**)&vptr, pchar_descriptor, 0) == alaqil_OK) {
	if (cptr) *cptr = vptr;
	if (psize) *psize = vptr ? (strlen(vptr) + 1) : 0;
	if (alloc) *alloc = alaqil_OLDOBJ;
	return alaqil_OK;
      }
    }
  }
  return alaqil_TypeError;
}
}

%fragment("alaqil_FromCharPtrAndSize","header") {
alaqilINTERNINLINE SV *
alaqil_FromCharPtrAndSize(const char* carray, size_t size)
{
  SV *obj = sv_newmortal();
  if (carray) {
    sv_setpvn(obj, carray, size);
  } else {
    sv_setsv(obj, &PL_sv_undef);
  }
  return obj;
}
}

