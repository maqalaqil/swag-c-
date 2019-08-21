/* ------------------------------------------------------------
 * Primitive Types
 * ------------------------------------------------------------ */

/* boolean */

%fragment(alaqil_From_frag(bool),"header") {
alaqilINTERNINLINE PyObject*
  alaqil_From_dec(bool)(bool value)
{
  return PyBool_FromLong(value ? 1 : 0);
}
}

#ifdef alaqil_PYTHON_LEGACY_BOOL
// Default prior to alaqil 3.0.0
%fragment(alaqil_AsVal_frag(bool),"header",
	  fragment=alaqil_AsVal_frag(long)) {
alaqilINTERN int
alaqil_AsVal_dec(bool)(PyObject *obj, bool *val)
{
  int r = PyObject_IsTrue(obj);
  if (r == -1)
    return alaqil_ERROR;
  if (val) *val = r ? true : false;
  return alaqil_OK;
}
}
#else
%fragment(alaqil_AsVal_frag(bool),"header",
	  fragment=alaqil_AsVal_frag(long)) {
alaqilINTERN int
alaqil_AsVal_dec(bool)(PyObject *obj, bool *val)
{
  int r;
  if (!PyBool_Check(obj))
    return alaqil_ERROR;
  r = PyObject_IsTrue(obj);
  if (r == -1)
    return alaqil_ERROR;
  if (val) *val = r ? true : false;
  return alaqil_OK;
}
}
#endif

/* int */

%fragment(alaqil_From_frag(int),"header") {
alaqilINTERNINLINE PyObject*
  alaqil_From_dec(int)(int value)
{
  return PyInt_FromLong((long) value);
}
}

/* unsigned int */

%fragment(alaqil_From_frag(unsigned int),"header") {
alaqilINTERNINLINE PyObject*
  alaqil_From_dec(unsigned int)(unsigned int value)
{
  return PyInt_FromSize_t((size_t) value);
}
}

/* long */

%fragment(alaqil_From_frag(long),"header") {
  %define_as(alaqil_From_dec(long),           PyInt_FromLong)
}

%fragment(alaqil_AsVal_frag(long),"header",
	  fragment="alaqil_CanCastAsInteger") {
alaqilINTERN int
alaqil_AsVal_dec(long)(PyObject *obj, long* val)
{
%#if PY_VERSION_HEX < 0x03000000
  if (PyInt_Check(obj)) {
    if (val) *val = PyInt_AsLong(obj);
    return alaqil_OK;
  } else
%#endif
  if (PyLong_Check(obj)) {
    long v = PyLong_AsLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return alaqil_OK;
    } else {
      PyErr_Clear();
      return alaqil_OverflowError;
    }
  }
%#ifdef alaqil_PYTHON_CAST_MODE
  {
    int dispatch = 0;
    long v = PyInt_AsLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return alaqil_AddCast(alaqil_OK);
    } else {
      PyErr_Clear();
    }
    if (!dispatch) {
      double d;
      int res = alaqil_AddCast(alaqil_AsVal(double)(obj,&d));
      if (alaqil_IsOK(res) && alaqil_CanCastAsInteger(&d, LONG_MIN, LONG_MAX)) {
	if (val) *val = (long)(d);
	return res;
      }
    }
  }
%#endif
  return alaqil_TypeError;
}
}

/* unsigned long */

%fragment(alaqil_From_frag(unsigned long),"header",
	  fragment=alaqil_From_frag(long)) {
alaqilINTERNINLINE PyObject* 
alaqil_From_dec(unsigned long)(unsigned long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromUnsignedLong(value) : PyInt_FromLong(%numeric_cast(value,long));
}
}

%fragment(alaqil_AsVal_frag(unsigned long),"header",
	  fragment="alaqil_CanCastAsInteger") {
alaqilINTERN int
alaqil_AsVal_dec(unsigned long)(PyObject *obj, unsigned long *val) 
{
%#if PY_VERSION_HEX < 0x03000000
  if (PyInt_Check(obj)) {
    long v = PyInt_AsLong(obj);
    if (v >= 0) {
      if (val) *val = v;
      return alaqil_OK;
    } else {
      return alaqil_OverflowError;
    }
  } else
%#endif
  if (PyLong_Check(obj)) {
    unsigned long v = PyLong_AsUnsignedLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return alaqil_OK;
    } else {
      PyErr_Clear();
      return alaqil_OverflowError;
    }
  }
%#ifdef alaqil_PYTHON_CAST_MODE
  {
    int dispatch = 0;
    unsigned long v = PyLong_AsUnsignedLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return alaqil_AddCast(alaqil_OK);
    } else {
      PyErr_Clear();
    }
    if (!dispatch) {
      double d;
      int res = alaqil_AddCast(alaqil_AsVal(double)(obj,&d));
      if (alaqil_IsOK(res) && alaqil_CanCastAsInteger(&d, 0, ULONG_MAX)) {
	if (val) *val = (unsigned long)(d);
	return res;
      }
    }
  }
%#endif
  return alaqil_TypeError;
}
}

/* long long */

%fragment(alaqil_From_frag(long long),"header",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERNINLINE PyObject* 
alaqil_From_dec(long long)(long long value)
{
  return ((value < LONG_MIN) || (value > LONG_MAX)) ?
    PyLong_FromLongLong(value) : PyInt_FromLong(%numeric_cast(value,long));
}
%#endif
}

%fragment(alaqil_AsVal_frag(long long),"header",
	  fragment=alaqil_AsVal_frag(long),
	  fragment="alaqil_CanCastAsInteger",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERN int
alaqil_AsVal_dec(long long)(PyObject *obj, long long *val)
{
  int res = alaqil_TypeError;
  if (PyLong_Check(obj)) {
    long long v = PyLong_AsLongLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return alaqil_OK;
    } else {
      PyErr_Clear();
      res = alaqil_OverflowError;
    }
  } else {
    long v;
    res = alaqil_AsVal(long)(obj,&v);
    if (alaqil_IsOK(res)) {
      if (val) *val = v;
      return res;
    }
  }
%#ifdef alaqil_PYTHON_CAST_MODE
  {
    const double mant_max = 1LL << DBL_MANT_DIG;
    const double mant_min = -mant_max;
    double d;
    res = alaqil_AsVal(double)(obj,&d);
    if (alaqil_IsOK(res) && !alaqil_CanCastAsInteger(&d, mant_min, mant_max))
      return alaqil_OverflowError;
    if (alaqil_IsOK(res) && alaqil_CanCastAsInteger(&d, mant_min, mant_max)) {
      if (val) *val = (long long)(d);
      return alaqil_AddCast(res);
    }
    res = alaqil_TypeError;
  }
%#endif
  return res;
}
%#endif
}

/* unsigned long long */

%fragment(alaqil_From_frag(unsigned long long),"header",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERNINLINE PyObject* 
alaqil_From_dec(unsigned long long)(unsigned long long value)
{
  return (value > LONG_MAX) ?
    PyLong_FromUnsignedLongLong(value) : PyInt_FromLong(%numeric_cast(value,long));
}
%#endif
}

%fragment(alaqil_AsVal_frag(unsigned long long),"header",
	  fragment=alaqil_AsVal_frag(unsigned long),
	  fragment="alaqil_CanCastAsInteger",
	  fragment="alaqil_LongLongAvailable") {
%#ifdef alaqil_LONG_LONG_AVAILABLE
alaqilINTERN int
alaqil_AsVal_dec(unsigned long long)(PyObject *obj, unsigned long long *val)
{
  int res = alaqil_TypeError;
  if (PyLong_Check(obj)) {
    unsigned long long v = PyLong_AsUnsignedLongLong(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return alaqil_OK;
    } else {
      PyErr_Clear();
      res = alaqil_OverflowError;
    }
  } else {
    unsigned long v;
    res = alaqil_AsVal(unsigned long)(obj,&v);
    if (alaqil_IsOK(res)) {
      if (val) *val = v;
      return res;
    }
  }
%#ifdef alaqil_PYTHON_CAST_MODE
  {
    const double mant_max = 1LL << DBL_MANT_DIG;
    double d;
    res = alaqil_AsVal(double)(obj,&d);
    if (alaqil_IsOK(res) && !alaqil_CanCastAsInteger(&d, 0, mant_max))
      return alaqil_OverflowError;
    if (alaqil_IsOK(res) && alaqil_CanCastAsInteger(&d, 0, mant_max)) {
      if (val) *val = (unsigned long long)(d);
      return alaqil_AddCast(res);
    }
    res = alaqil_TypeError;
  }
%#endif
  return res;
}
%#endif
}

/* double */

%fragment(alaqil_From_frag(double),"header") {
  %define_as(alaqil_From_dec(double),          PyFloat_FromDouble)
}

%fragment(alaqil_AsVal_frag(double),"header") {
alaqilINTERN int
alaqil_AsVal_dec(double)(PyObject *obj, double *val)
{
  int res = alaqil_TypeError;
  if (PyFloat_Check(obj)) {
    if (val) *val = PyFloat_AsDouble(obj);
    return alaqil_OK;
%#if PY_VERSION_HEX < 0x03000000
  } else if (PyInt_Check(obj)) {
    if (val) *val = (double) PyInt_AsLong(obj);
    return alaqil_OK;
%#endif
  } else if (PyLong_Check(obj)) {
    double v = PyLong_AsDouble(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = v;
      return alaqil_OK;
    } else {
      PyErr_Clear();
    }
  }
%#ifdef alaqil_PYTHON_CAST_MODE
  {
    int dispatch = 0;
    double d = PyFloat_AsDouble(obj);
    if (!PyErr_Occurred()) {
      if (val) *val = d;
      return alaqil_AddCast(alaqil_OK);
    } else {
      PyErr_Clear();
    }
    if (!dispatch) {
      long v = PyLong_AsLong(obj);
      if (!PyErr_Occurred()) {
	if (val) *val = v;
	return alaqil_AddCast(alaqil_AddCast(alaqil_OK));
      } else {
	PyErr_Clear();
      }
    }
  }
%#endif
  return res;
}
}



