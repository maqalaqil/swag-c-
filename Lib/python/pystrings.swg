/* ------------------------------------------------------------
 *  utility methods for char strings 
 * ------------------------------------------------------------ */
%fragment("alaqil_AsCharPtrAndSize","header",fragment="alaqil_pchar_descriptor") {
alaqilINTERN int
alaqil_AsCharPtrAndSize(PyObject *obj, char** cptr, size_t* psize, int *alloc)
{
%#if PY_VERSION_HEX>=0x03000000
%#if defined(alaqil_PYTHON_STRICT_BYTE_CHAR)
  if (PyBytes_Check(obj))
%#else
  if (PyUnicode_Check(obj))
%#endif
%#else  
  if (PyString_Check(obj))
%#endif
  {
    char *cstr; Py_ssize_t len;
    int ret = alaqil_OK;
%#if PY_VERSION_HEX>=0x03000000
%#if !defined(alaqil_PYTHON_STRICT_BYTE_CHAR)
    if (!alloc && cptr) {
        /* We can't allow converting without allocation, since the internal
           representation of string in Python 3 is UCS-2/UCS-4 but we require
           a UTF-8 representation.
           TODO(bhy) More detailed explanation */
        return alaqil_RuntimeError;
    }
    obj = PyUnicode_AsUTF8String(obj);
    if (!obj)
      return alaqil_TypeError;
    if (alloc)
      *alloc = alaqil_NEWOBJ;
%#endif
    PyBytes_AsStringAndSize(obj, &cstr, &len);
%#else
    PyString_AsStringAndSize(obj, &cstr, &len);
%#endif
    if (cptr) {
      if (alloc) {
	if (*alloc == alaqil_NEWOBJ) {
	  *cptr = %new_copy_array(cstr, len + 1, char);
	  *alloc = alaqil_NEWOBJ;
	} else {
	  *cptr = cstr;
	  *alloc = alaqil_OLDOBJ;
	}
      } else {
%#if PY_VERSION_HEX>=0x03000000
%#if defined(alaqil_PYTHON_STRICT_BYTE_CHAR)
	*cptr = PyBytes_AsString(obj);
%#else
	assert(0); /* Should never reach here with Unicode strings in Python 3 */
%#endif
%#else
	*cptr = alaqil_Python_str_AsChar(obj);
        if (!*cptr)
          ret = alaqil_TypeError;
%#endif
      }
    }
    if (psize) *psize = len + 1;
%#if PY_VERSION_HEX>=0x03000000 && !defined(alaqil_PYTHON_STRICT_BYTE_CHAR)
    Py_XDECREF(obj);
%#endif
    return ret;
  } else {
%#if defined(alaqil_PYTHON_2_UNICODE)
%#if defined(alaqil_PYTHON_STRICT_BYTE_CHAR)
%#error "Cannot use both alaqil_PYTHON_2_UNICODE and alaqil_PYTHON_STRICT_BYTE_CHAR at once"
%#endif
%#if PY_VERSION_HEX<0x03000000
    if (PyUnicode_Check(obj)) {
      char *cstr; Py_ssize_t len;
      if (!alloc && cptr) {
        return alaqil_RuntimeError;
      }
      obj = PyUnicode_AsUTF8String(obj);
      if (!obj)
        return alaqil_TypeError;
      if (PyString_AsStringAndSize(obj, &cstr, &len) != -1) {
        if (cptr) {
          if (alloc) *alloc = alaqil_NEWOBJ;
          *cptr = %new_copy_array(cstr, len + 1, char);
        }
        if (psize) *psize = len + 1;

        Py_XDECREF(obj);
        return alaqil_OK;
      } else {
        Py_XDECREF(obj);
      }
    }
%#endif
%#endif

    alaqil_type_info* pchar_descriptor = alaqil_pchar_descriptor();
    if (pchar_descriptor) {
      void* vptr = 0;
      if (alaqil_ConvertPtr(obj, &vptr, pchar_descriptor, 0) == alaqil_OK) {
	if (cptr) *cptr = (char *) vptr;
	if (psize) *psize = vptr ? (strlen((char *)vptr) + 1) : 0;
	if (alloc) *alloc = alaqil_OLDOBJ;
	return alaqil_OK;
      }
    }
  }
  return alaqil_TypeError;
}
}

%fragment("alaqil_FromCharPtrAndSize","header",fragment="alaqil_pchar_descriptor") {
alaqilINTERNINLINE PyObject *
alaqil_FromCharPtrAndSize(const char* carray, size_t size)
{
  if (carray) {
    if (size > INT_MAX) {
      alaqil_type_info* pchar_descriptor = alaqil_pchar_descriptor();
      return pchar_descriptor ? 
	alaqil_InternalNewPointerObj(%const_cast(carray,char *), pchar_descriptor, 0) : alaqil_Py_Void();
    } else {
%#if PY_VERSION_HEX >= 0x03000000
%#if defined(alaqil_PYTHON_STRICT_BYTE_CHAR)
      return PyBytes_FromStringAndSize(carray, %numeric_cast(size, Py_ssize_t));
%#else
      return PyUnicode_DecodeUTF8(carray, %numeric_cast(size, Py_ssize_t), "surrogateescape");
%#endif
%#else
      return PyString_FromStringAndSize(carray, %numeric_cast(size, Py_ssize_t));
%#endif
    }
  } else {
    return alaqil_Py_Void();
  }
}
}

