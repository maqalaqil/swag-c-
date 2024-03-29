/* -----------------------------------------------------------------------------
 * error manipulation
 * ----------------------------------------------------------------------------- */

alaqilRUNTIME PyObject*
alaqil_Python_ErrorType(int code) {
  PyObject* type = 0;
  switch(code) {
  case alaqil_MemoryError:
    type = PyExc_MemoryError;
    break;
  case alaqil_IOError:
    type = PyExc_IOError;
    break;
  case alaqil_RuntimeError:
    type = PyExc_RuntimeError;
    break;
  case alaqil_IndexError:
    type = PyExc_IndexError;
    break;
  case alaqil_TypeError:
    type = PyExc_TypeError;
    break;
  case alaqil_DivisionByZero:
    type = PyExc_ZeroDivisionError;
    break;
  case alaqil_OverflowError:
    type = PyExc_OverflowError;
    break;
  case alaqil_SyntaxError:
    type = PyExc_SyntaxError;
    break;
  case alaqil_ValueError:
    type = PyExc_ValueError;
    break;
  case alaqil_SystemError:
    type = PyExc_SystemError;
    break;
  case alaqil_AttributeError:
    type = PyExc_AttributeError;
    break;
  default:
    type = PyExc_RuntimeError;
  }
  return type;
}


alaqilRUNTIME void
alaqil_Python_AddErrorMsg(const char* mesg)
{
  PyObject *type = 0;
  PyObject *value = 0;
  PyObject *traceback = 0;

  if (PyErr_Occurred())
    PyErr_Fetch(&type, &value, &traceback);
  if (value) {
    PyObject *old_str = PyObject_Str(value);
    const char *tmp = alaqil_Python_str_AsChar(old_str);
    PyErr_Clear();
    Py_XINCREF(type);
    if (tmp)
      PyErr_Format(type, "%s %s", tmp, mesg);
    else
      PyErr_Format(type, "%s", mesg);
    alaqil_Python_str_DelForPy3(tmp);
    Py_DECREF(old_str);
    Py_DECREF(value);
  } else {
    PyErr_SetString(PyExc_RuntimeError, mesg);
  }
}

alaqilRUNTIME int
alaqil_Python_TypeErrorOccurred(PyObject *obj)
{
  PyObject *error;
  if (obj)
    return 0;
  error = PyErr_Occurred();
  return error && PyErr_GivenExceptionMatches(error, PyExc_TypeError);
}

alaqilRUNTIME void
alaqil_Python_RaiseOrModifyTypeError(const char *message)
{
  if (alaqil_Python_TypeErrorOccurred(NULL)) {
    /* Use existing TypeError to preserve stacktrace and enhance with given message */
    PyObject *newvalue;
    PyObject *type = NULL, *value = NULL, *traceback = NULL;
    PyErr_Fetch(&type, &value, &traceback);
#if PY_VERSION_HEX >= 0x03000000
    newvalue = PyUnicode_FromFormat("%S\nAdditional information:\n%s", value, message);
#else
    newvalue = PyString_FromFormat("%s\nAdditional information:\n%s", PyString_AsString(value), message);
#endif
    Py_XDECREF(value);
    PyErr_Restore(type, newvalue, traceback);
  } else {
    /* Raise TypeError using given message */
    PyErr_SetString(PyExc_TypeError, message);
  }
}
