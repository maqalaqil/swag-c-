/* -----------------------------------------------------------------------------
 * file.i
 *
 * Typemaps for FILE*
 * ----------------------------------------------------------------------------- */

%types(FILE *);

/* defining basic methods */
%fragment("alaqil_AsValFilePtr","header") {
alaqilINTERN int
alaqil_AsValFilePtr(PyObject *obj, FILE **val) {
  static alaqil_type_info* desc = 0;
  void *vptr = 0;
  if (!desc) desc = alaqil_TypeQuery("FILE *");
  if ((alaqil_ConvertPtr(obj, &vptr, desc, 0)) == alaqil_OK) {
    if (val) *val = (FILE *)vptr;
    return alaqil_OK;
  }
%#if PY_VERSION_HEX < 0x03000000
  if (PyFile_Check(obj)) {
    if (val) *val =  PyFile_AsFile(obj);
    return alaqil_OK;
  }
%#endif
  return alaqil_TypeError;
}
}


%fragment("alaqil_AsFilePtr","header",fragment="alaqil_AsValFilePtr") {
alaqilINTERNINLINE FILE*
alaqil_AsFilePtr(PyObject *obj) {
  FILE *val = 0;
  alaqil_AsValFilePtr(obj, &val);
  return val;
}
}

/* defining the typemaps */
%typemaps_asval(%checkcode(POINTER), alaqil_AsValFilePtr, "alaqil_AsValFilePtr", FILE*);
