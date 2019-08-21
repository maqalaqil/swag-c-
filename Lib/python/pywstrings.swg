/* ------------------------------------------------------------
 *  utility methods for wchar_t strings 
 * ------------------------------------------------------------ */

%{
#if PY_VERSION_HEX >= 0x03020000
# define alaqilPY_UNICODE_ARG(obj) ((PyObject*) (obj))
#else
# define alaqilPY_UNICODE_ARG(obj) ((PyUnicodeObject*) (obj))
#endif
%}

%fragment("alaqil_AsWCharPtrAndSize","header",fragment="<wchar.h>",fragment="alaqil_pwchar_descriptor") {
alaqilINTERN int
alaqil_AsWCharPtrAndSize(PyObject *obj, wchar_t **cptr, size_t *psize, int *alloc)
{
  PyObject *tmp = 0;
  int isunicode = PyUnicode_Check(obj);
%#if PY_VERSION_HEX < 0x03000000 && !defined(alaqil_PYTHON_STRICT_UNICODE_WCHAR)
  if (!isunicode && PyString_Check(obj)) {
    tmp = PyUnicode_FromObject(obj);
    if (tmp) {
      isunicode = 1;
      obj = tmp;
    } else {
      PyErr_Clear();
      return alaqil_TypeError;
    }
  }
%#endif
  if (isunicode) {
%#if PY_VERSION_HEX >= 0x03030000
    Py_ssize_t len = PyUnicode_GetLength(obj);
%#else
    Py_ssize_t len = PyUnicode_GetSize(obj);
%#endif
    if (cptr) {
      Py_ssize_t length;
      *cptr = %new_array(len + 1, wchar_t);
      length = PyUnicode_AsWideChar(alaqilPY_UNICODE_ARG(obj), *cptr, len);
      if (length == -1) {
        PyErr_Clear();
        Py_XDECREF(tmp);
        return alaqil_TypeError;
      }
      (*cptr)[length] = 0;
    }
    if (psize) *psize = (size_t) len + 1;
    if (alloc) *alloc = cptr ? alaqil_NEWOBJ : 0;
    Py_XDECREF(tmp);
    return alaqil_OK;
  } else {
    alaqil_type_info* pwchar_descriptor = alaqil_pwchar_descriptor();
    if (pwchar_descriptor) {
      void * vptr = 0;
      if (alaqil_ConvertPtr(obj, &vptr, pwchar_descriptor, 0) == alaqil_OK) {
	if (cptr) *cptr = (wchar_t *)vptr;
	if (psize) *psize = vptr ? (wcslen((wchar_t *)vptr) + 1) : 0;
	return alaqil_OK;
      }
    }
  }
  return alaqil_TypeError;
}
}

%fragment("alaqil_FromWCharPtrAndSize","header",fragment="<wchar.h>",fragment="alaqil_pwchar_descriptor") {
alaqilINTERNINLINE PyObject *
alaqil_FromWCharPtrAndSize(const wchar_t * carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      alaqil_type_info* pwchar_descriptor = alaqil_pwchar_descriptor();
      return pwchar_descriptor ? 
	alaqil_InternalNewPointerObj(%const_cast(carray,wchar_t *), pwchar_descriptor, 0) : alaqil_Py_Void();
    } else {
      return PyUnicode_FromWideChar(carray, %numeric_cast(size, Py_ssize_t));
    }
  } else {
    return alaqil_Py_Void();
  }
}
}


