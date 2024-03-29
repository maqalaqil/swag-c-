#ifdef __cplusplus
extern "C" {
#endif

alaqilINTERN Py_hash_t
alaqilPyObject_hash(PyObject *obj) {
  alaqilPyObject *sobj = (alaqilPyObject *)obj;
  void *ptr = sobj->ptr;
  return (Py_hash_t)ptr;
}

alaqilINTERN Py_hash_t
alaqil_PyNumber_AsPyHash(PyObject *obj) {
  Py_hash_t result = -1;
#if PY_VERSION_HEX < 0x03020000
  if (PyInt_Check(obj))
    result = PyInt_AsLong(obj);
  else if (PyLong_Check(obj))
    result = PyLong_AsLong(obj);
#else
  if (PyNumber_Check(obj))
    result = PyNumber_AsSsize_t(obj, NULL);
#endif
  else
    PyErr_Format(PyExc_TypeError, "Wrong type for hash function");
  return PyErr_Occurred() ? -1 : result;
}

alaqilINTERN int
alaqilPyBuiltin_BadInit(PyObject *self, PyObject *alaqilUNUSEDPARM(args), PyObject *alaqilUNUSEDPARM(kwds)) {
  PyErr_Format(PyExc_TypeError, "Cannot create new instances of type '%.300s'", self->ob_type->tp_name);
  return -1;
}

alaqilINTERN void
alaqilPyBuiltin_BadDealloc(PyObject *obj) {
  alaqilPyObject *sobj = (alaqilPyObject *)obj;
  if (sobj->own) {
    PyErr_Format(PyExc_TypeError, "alaqil detected a memory leak in type '%.300s': no callable destructor found.", obj->ob_type->tp_name);
  }
}

typedef struct {
  PyCFunction get;
  PyCFunction set;
} alaqilPyGetSet;

alaqilINTERN PyObject *
alaqilPyBuiltin_GetterClosure (PyObject *obj, void *closure) {
  alaqilPyGetSet *getset;
  PyObject *tuple, *result;
  if (!closure)
    return alaqil_Py_Void();
  getset = (alaqilPyGetSet *)closure;
  if (!getset->get)
    return alaqil_Py_Void();
  tuple = PyTuple_New(0);
  assert(tuple);
  result = (*getset->get)(obj, tuple);
  Py_DECREF(tuple);
  return result;
}

alaqilINTERN PyObject *
alaqilPyBuiltin_FunpackGetterClosure (PyObject *obj, void *closure) {
  alaqilPyGetSet *getset;
  PyObject *result;
  if (!closure)
    return alaqil_Py_Void();
  getset = (alaqilPyGetSet *)closure;
  if (!getset->get)
    return alaqil_Py_Void();
  result = (*getset->get)(obj, NULL);
  return result;
}

alaqilINTERN int
alaqilPyBuiltin_SetterClosure (PyObject *obj, PyObject *val, void *closure) {
  alaqilPyGetSet *getset;
  PyObject *tuple, *result;
  if (!closure) {
    PyErr_Format(PyExc_TypeError, "Missing getset closure");
    return -1;
  }
  getset = (alaqilPyGetSet *)closure;
  if (!getset->set) {
    PyErr_Format(PyExc_TypeError, "Illegal member variable assignment in type '%.300s'", obj->ob_type->tp_name);
    return -1;
  }
  tuple = PyTuple_New(1);
  assert(tuple);
  Py_INCREF(val);
  PyTuple_SET_ITEM(tuple, 0, val);
  result = (*getset->set)(obj, tuple);
  Py_DECREF(tuple);
  Py_XDECREF(result);
  return result ? 0 : -1;
}

alaqilINTERN int
alaqilPyBuiltin_FunpackSetterClosure (PyObject *obj, PyObject *val, void *closure) {
  alaqilPyGetSet *getset;
  PyObject *result;
  if (!closure) {
    PyErr_Format(PyExc_TypeError, "Missing getset closure");
    return -1;
  }
  getset = (alaqilPyGetSet *)closure;
  if (!getset->set) {
    PyErr_Format(PyExc_TypeError, "Illegal member variable assignment in type '%.300s'", obj->ob_type->tp_name);
    return -1;
  }
  result = (*getset->set)(obj, val);
  Py_XDECREF(result);
  return result ? 0 : -1;
}

alaqilINTERN void
alaqilPyStaticVar_dealloc(PyDescrObject *descr) {
  _PyObject_GC_UNTRACK(descr);
  Py_XDECREF(PyDescr_TYPE(descr));
  Py_XDECREF(PyDescr_NAME(descr));
  PyObject_GC_Del(descr);
}

alaqilINTERN PyObject *
alaqilPyStaticVar_repr(PyGetSetDescrObject *descr) {
#if PY_VERSION_HEX >= 0x03000000

  return PyUnicode_FromFormat("<class attribute '%S' of type '%s'>", PyDescr_NAME(descr), PyDescr_TYPE(descr)->tp_name);
#else
  return PyString_FromFormat("<class attribute '%s' of type '%s'>", PyString_AsString(PyDescr_NAME(descr)), PyDescr_TYPE(descr)->tp_name);
#endif
}

alaqilINTERN int
alaqilPyStaticVar_traverse(PyObject *self, visitproc visit, void *arg) {
  PyDescrObject *descr;
  descr = (PyDescrObject *)self;
  Py_VISIT((PyObject*) PyDescr_TYPE(descr));
  return 0;
}

alaqilINTERN PyObject *
alaqilPyStaticVar_get(PyGetSetDescrObject *descr, PyObject *obj, PyObject *alaqilUNUSEDPARM(type)) {
  if (descr->d_getset->get != NULL)
    return descr->d_getset->get(obj, descr->d_getset->closure);
#if PY_VERSION_HEX >= 0x03000000
  PyErr_Format(PyExc_AttributeError, "attribute '%.300S' of '%.100s' objects is not readable", PyDescr_NAME(descr), PyDescr_TYPE(descr)->tp_name);
#else
  PyErr_Format(PyExc_AttributeError, "attribute '%.300s' of '%.100s' objects is not readable", PyString_AsString(PyDescr_NAME(descr)), PyDescr_TYPE(descr)->tp_name);
#endif
  return NULL;
}

alaqilINTERN int
alaqilPyStaticVar_set(PyGetSetDescrObject *descr, PyObject *obj, PyObject *value) {
  if (descr->d_getset->set != NULL)
    return descr->d_getset->set(obj, value, descr->d_getset->closure);
#if PY_VERSION_HEX >= 0x03000000
  PyErr_Format(PyExc_AttributeError, "attribute '%.300S' of '%.100s' objects is not writable", PyDescr_NAME(descr), PyDescr_TYPE(descr)->tp_name);
#else
  PyErr_Format(PyExc_AttributeError, "attribute '%.300s' of '%.100s' objects is not writable", PyString_AsString(PyDescr_NAME(descr)), PyDescr_TYPE(descr)->tp_name);
#endif
  return -1;
}

alaqilINTERN int
alaqilPyObjectType_setattro(PyObject *typeobject, PyObject *name, PyObject *value) {
  PyObject *attribute;
  PyTypeObject *type;
  descrsetfunc local_set;

  assert(PyType_Check(typeobject));
  type = (PyTypeObject *)typeobject;
  attribute = _PyType_Lookup(type, name);
  if (attribute != NULL) {
    /* Implement descriptor functionality, if any */
    local_set = attribute->ob_type->tp_descr_set;
    if (local_set != NULL)
      return local_set(attribute, (PyObject *)type, value);
#if PY_VERSION_HEX >= 0x03000000
    PyErr_Format(PyExc_AttributeError, "cannot modify read-only attribute '%.50s.%.400S'", type->tp_name, name);
#else 
    PyErr_Format(PyExc_AttributeError, "cannot modify read-only attribute '%.50s.%.400s'", type->tp_name, PyString_AS_STRING(name));
#endif
  } else {
#if PY_VERSION_HEX >= 0x03000000
    PyErr_Format(PyExc_AttributeError, "type '%.50s' has no attribute '%.400S'", type->tp_name, name);
#else
    PyErr_Format(PyExc_AttributeError, "type '%.50s' has no attribute '%.400s'", type->tp_name, PyString_AS_STRING(name));
#endif
  }

  return -1;
}

alaqilINTERN PyTypeObject*
alaqilPyStaticVar_Type(void) {
  static PyTypeObject staticvar_type;
  static int type_init = 0;
  if (!type_init) {
    const PyTypeObject tmp = {
#if PY_VERSION_HEX >= 0x03000000
      PyVarObject_HEAD_INIT(&PyType_Type, 0)
#else
      PyObject_HEAD_INIT(&PyType_Type)
      0,                                        /* ob_size */
#endif
      "alaqil_static_var_getset_descriptor",      /* tp_name */
      sizeof(PyGetSetDescrObject),              /* tp_basicsize */
      0,                                        /* tp_itemsize */
      (destructor)alaqilPyStaticVar_dealloc,      /* tp_dealloc */
      0,                                        /* tp_print */
      0,                                        /* tp_getattr */
      0,                                        /* tp_setattr */
      0,                                        /* tp_compare */
      (reprfunc)alaqilPyStaticVar_repr,           /* tp_repr */
      0,                                        /* tp_as_number */
      0,                                        /* tp_as_sequence */
      0,                                        /* tp_as_mapping */
      0,                                        /* tp_hash */
      0,                                        /* tp_call */
      0,                                        /* tp_str */
      PyObject_GenericGetAttr,                  /* tp_getattro */
      0,                                        /* tp_setattro */
      0,                                        /* tp_as_buffer */
      Py_TPFLAGS_DEFAULT|Py_TPFLAGS_HAVE_GC|Py_TPFLAGS_HAVE_CLASS, /* tp_flags */
      0,                                        /* tp_doc */
      alaqilPyStaticVar_traverse,                 /* tp_traverse */
      0,                                        /* tp_clear */
      0,                                        /* tp_richcompare */
      0,                                        /* tp_weaklistoffset */
      0,                                        /* tp_iter */
      0,                                        /* tp_iternext */
      0,                                        /* tp_methods */
      0,                                        /* tp_members */
      0,                                        /* tp_getset */
      0,                                        /* tp_base */
      0,                                        /* tp_dict */
      (descrgetfunc)alaqilPyStaticVar_get,        /* tp_descr_get */
      (descrsetfunc)alaqilPyStaticVar_set,        /* tp_descr_set */
      0,                                        /* tp_dictoffset */
      0,                                        /* tp_init */
      0,                                        /* tp_alloc */
      0,                                        /* tp_new */
      0,                                        /* tp_free */
      0,                                        /* tp_is_gc */
      0,                                        /* tp_bases */
      0,                                        /* tp_mro */
      0,                                        /* tp_cache */
      0,                                        /* tp_subclasses */
      0,                                        /* tp_weaklist */
      0,                                        /* tp_del */
      0,                                        /* tp_version_tag */
#if PY_VERSION_HEX >= 0x03040000
      0,                                        /* tp_finalize */
#endif
#ifdef COUNT_ALLOCS
      0,                                        /* tp_allocs */
      0,                                        /* tp_frees */
      0,                                        /* tp_maxalloc */
      0,                                        /* tp_prev */
      0                                         /* tp_next */
#endif
    };
    staticvar_type = tmp;
    type_init = 1;
    if (PyType_Ready(&staticvar_type) < 0)
      return NULL;
  }
  return &staticvar_type;
}

alaqilINTERN PyTypeObject*
alaqilPyObjectType(void) {
  static char alaqilpyobjecttype_doc[] = "Metaclass for alaqil wrapped types";
  static PyTypeObject alaqilpyobjecttype_type;
  static int type_init = 0;
  if (!type_init) {
    const PyTypeObject tmp = {
#if PY_VERSION_HEX >= 0x03000000
      PyVarObject_HEAD_INIT(&PyType_Type, 0)
#else
      PyObject_HEAD_INIT(&PyType_Type)
      0,                                        /* ob_size */
#endif
      "alaqilPyObjectType",                       /* tp_name */
      PyType_Type.tp_basicsize,                 /* tp_basicsize */
      0,                                        /* tp_itemsize */
      0,                                        /* tp_dealloc */
      0,                                        /* tp_print */
      0,                                        /* tp_getattr */
      0,                                        /* tp_setattr */
      0,                                        /* tp_compare */
      0,                                        /* tp_repr */
      0,                                        /* tp_as_number */
      0,                                        /* tp_as_sequence */
      0,                                        /* tp_as_mapping */
      0,                                        /* tp_hash */
      0,                                        /* tp_call */
      0,                                        /* tp_str */
      0,                                        /* tp_getattro */
      alaqilPyObjectType_setattro,                /* tp_setattro */
      0,                                        /* tp_as_buffer */
      Py_TPFLAGS_DEFAULT|Py_TPFLAGS_HAVE_CLASS, /* tp_flags */
      alaqilpyobjecttype_doc,                     /* tp_doc */
      0,                                        /* tp_traverse */
      0,                                        /* tp_clear */
      0,                                        /* tp_richcompare */
      0,                                        /* tp_weaklistoffset */
      0,                                        /* tp_iter */
      0,                                        /* tp_iternext */
      0,                                        /* tp_methods */
      0,                                        /* tp_members */
      0,                                        /* tp_getset */
      0,                                        /* tp_base */
      0,                                        /* tp_dict */
      0,                                        /* tp_descr_get */
      0,                                        /* tp_descr_set */
      0,                                        /* tp_dictoffset */
      0,                                        /* tp_init */
      0,                                        /* tp_alloc */
      0,                                        /* tp_new */
      0,                                        /* tp_free */
      0,                                        /* tp_is_gc */
      0,                                        /* tp_bases */
      0,                                        /* tp_mro */
      0,                                        /* tp_cache */
      0,                                        /* tp_subclasses */
      0,                                        /* tp_weaklist */
      0,                                        /* tp_del */
      0,                                        /* tp_version_tag */
#if PY_VERSION_HEX >= 0x03040000
      0,                                        /* tp_finalize */
#endif
#ifdef COUNT_ALLOCS
      0,                                        /* tp_allocs */
      0,                                        /* tp_frees */
      0,                                        /* tp_maxalloc */
      0,                                        /* tp_prev */
      0                                         /* tp_next */
#endif
    };
    alaqilpyobjecttype_type = tmp;
    type_init = 1;
    alaqilpyobjecttype_type.tp_base = &PyType_Type;
    if (PyType_Ready(&alaqilpyobjecttype_type) < 0)
      return NULL;
  }
  return &alaqilpyobjecttype_type;
}

alaqilINTERN PyGetSetDescrObject *
alaqilPyStaticVar_new_getset(PyTypeObject *type, PyGetSetDef *getset) {

  PyGetSetDescrObject *descr;
  descr = (PyGetSetDescrObject *)PyType_GenericAlloc(alaqilPyStaticVar_Type(), 0);
  assert(descr);
  Py_XINCREF(type);
  PyDescr_TYPE(descr) = type;
  PyDescr_NAME(descr) = PyString_InternFromString(getset->name);
  descr->d_getset = getset;
  if (PyDescr_NAME(descr) == NULL) {
    Py_DECREF(descr);
    descr = NULL;
  }
  return descr;
}

alaqilINTERN void
alaqilPyBuiltin_InitBases (PyTypeObject *type, PyTypeObject **bases) {
  Py_ssize_t base_count = 0;
  PyTypeObject **b;
  PyObject *tuple;
  Py_ssize_t i;

  if (!bases[0]) {
    bases[0] = alaqilPyObject_type();
    bases[1] = NULL;
  }
  type->tp_base = bases[0];
  Py_INCREF((PyObject *)bases[0]);
  for (b = bases; *b != NULL; ++b)
    ++base_count;
  tuple = PyTuple_New(base_count);
  for (i = 0; i < base_count; ++i) {
    Py_INCREF((PyObject *)bases[i]);
    PyTuple_SET_ITEM(tuple, i, (PyObject *)bases[i]);
  }
  type->tp_bases = tuple;
}

alaqilINTERN PyObject *
alaqilPyBuiltin_ThisClosure (PyObject *self, void *alaqilUNUSEDPARM(closure)) {
  PyObject *result;
  result = (PyObject *)alaqil_Python_GetalaqilThis(self);
  Py_XINCREF(result);
  return result;
}

alaqilINTERN void
alaqilPyBuiltin_SetMetaType (PyTypeObject *type, PyTypeObject *metatype)
{
#if PY_VERSION_HEX >= 0x03000000
    type->ob_base.ob_base.ob_type = metatype;
#else
    type->ob_type = metatype;
#endif
}


/* Start of callback function macros for use in PyTypeObject */

typedef PyObject *(*alaqilPyWrapperFunction)(PyObject *, PyObject *);

#define alaqilPY_UNARYFUNC_CLOSURE(wrapper)		\
alaqilINTERN PyObject *					\
wrapper##_unaryfunc_closure(PyObject *a) {		\
  return alaqilPyBuiltin_unaryfunc_closure(wrapper, a);	\
}
alaqilINTERN PyObject *
alaqilPyBuiltin_unaryfunc_closure(alaqilPyWrapperFunction wrapper, PyObject *a) {
  return wrapper(a, NULL);
}

#define alaqilPY_DESTRUCTOR_CLOSURE(wrapper)			\
alaqilINTERN void							\
wrapper##_destructor_closure(PyObject *a) {			\
    alaqilPyBuiltin_destructor_closure(wrapper, #wrapper, a);	\
}
alaqilINTERN void
alaqilPyBuiltin_destructor_closure(alaqilPyWrapperFunction wrapper, const char *wrappername, PyObject *a) {
  alaqilPyObject *sobj;
  sobj = (alaqilPyObject *)a;
  Py_XDECREF(sobj->dict);
  if (sobj->own) {
    PyObject *o;
    PyObject *type = 0, *value = 0, *traceback = 0;
    PyErr_Fetch(&type, &value, &traceback);
    o = wrapper(a, NULL);
    if (!o) {
      PyObject *deallocname = PyString_FromString(wrappername);
      PyErr_WriteUnraisable(deallocname);
      Py_DECREF(deallocname);
    }
    PyErr_Restore(type, value, traceback);
    Py_XDECREF(o);
  }
  if (PyType_IS_GC(a->ob_type)) {
    PyObject_GC_Del(a);
  } else {
    PyObject_Del(a);
  }
}

#define alaqilPY_INQUIRY_CLOSURE(wrapper)			\
alaqilINTERN int						\
wrapper##_inquiry_closure(PyObject *a) {		\
  return alaqilPyBuiltin_inquiry_closure(wrapper, a);	\
}
alaqilINTERN int
alaqilPyBuiltin_inquiry_closure(alaqilPyWrapperFunction wrapper, PyObject *a) {
  PyObject *pyresult;
  int result;
  pyresult = wrapper(a, NULL);
  result = pyresult && PyObject_IsTrue(pyresult) ? 1 : 0;
  Py_XDECREF(pyresult);
  return result;
}

#define alaqilPY_GETITERFUNC_CLOSURE(wrapper)		\
alaqilINTERN PyObject *					\
wrapper##_getiterfunc_closure(PyObject *a) {		\
  return alaqilPyBuiltin_getiterfunc_closure(wrapper, a);	\
}
alaqilINTERN PyObject *
alaqilPyBuiltin_getiterfunc_closure(alaqilPyWrapperFunction wrapper, PyObject *a) {
  return wrapper(a, NULL);
}

#define alaqilPY_BINARYFUNC_CLOSURE(wrapper)			\
alaqilINTERN PyObject *						\
wrapper##_binaryfunc_closure(PyObject *a, PyObject *b) {	\
  return alaqilPyBuiltin_binaryfunc_closure(wrapper, a, b);	\
}
alaqilINTERN PyObject *
alaqilPyBuiltin_binaryfunc_closure(alaqilPyWrapperFunction wrapper, PyObject *a, PyObject *b) {
  PyObject *tuple, *result;
  tuple = PyTuple_New(1);
  assert(tuple);
  Py_INCREF(b);
  PyTuple_SET_ITEM(tuple, 0, b);
  result = wrapper(a, tuple);
  Py_DECREF(tuple);
  return result;
}

typedef ternaryfunc ternarycallfunc;

#define alaqilPY_TERNARYFUNC_CLOSURE(wrapper)				\
alaqilINTERN PyObject *							\
wrapper##_ternaryfunc_closure(PyObject *a, PyObject *b, PyObject *c) {	\
  return alaqilPyBuiltin_ternaryfunc_closure(wrapper, a, b, c);		\
}
alaqilINTERN PyObject *
alaqilPyBuiltin_ternaryfunc_closure(alaqilPyWrapperFunction wrapper, PyObject *a, PyObject *b, PyObject *c) {
  PyObject *tuple, *result;
  tuple = PyTuple_New(2);
  assert(tuple);
  Py_INCREF(b);
  PyTuple_SET_ITEM(tuple, 0, b);
  Py_INCREF(c);
  PyTuple_SET_ITEM(tuple, 1, c);
  result = wrapper(a, tuple);
  Py_DECREF(tuple);
  return result;
}

#define alaqilPY_TERNARYCALLFUNC_CLOSURE(wrapper)					\
alaqilINTERN PyObject *								\
wrapper##_ternarycallfunc_closure(PyObject *a, PyObject *b, PyObject *c) {	\
  return alaqilPyBuiltin_ternarycallfunc_closure(wrapper, a, b, c);		\
}
alaqilINTERN PyObject *
alaqilPyBuiltin_ternarycallfunc_closure(alaqilPyWrapperFunction wrapper, PyObject *a, PyObject *b, PyObject *c) {
  (void) c;
  return wrapper(a, b);
}

#define alaqilPY_LENFUNC_CLOSURE(wrapper)			\
alaqilINTERN Py_ssize_t					\
wrapper##_lenfunc_closure(PyObject *a) {		\
  return alaqilPyBuiltin_lenfunc_closure(wrapper, a);	\
}
alaqilINTERN Py_ssize_t
alaqilPyBuiltin_lenfunc_closure(alaqilPyWrapperFunction wrapper, PyObject *a) {
  PyObject *resultobj;
  Py_ssize_t result;
  resultobj = wrapper(a, NULL);
  result = PyNumber_AsSsize_t(resultobj, NULL);
  Py_DECREF(resultobj);
  return result;
}

#define alaqilPY_SSIZESSIZEARGFUNC_CLOSURE(wrapper)				\
alaqilINTERN PyObject *								\
wrapper##_ssizessizeargfunc_closure(PyObject *a, Py_ssize_t b, Py_ssize_t c) {	\
  return alaqilPyBuiltin_ssizessizeargfunc_closure(wrapper, a, b, c);		\
}
alaqilINTERN PyObject *
alaqilPyBuiltin_ssizessizeargfunc_closure(alaqilPyWrapperFunction wrapper, PyObject *a, Py_ssize_t b, Py_ssize_t c) {
  PyObject *tuple, *result;
  tuple = PyTuple_New(2);
  assert(tuple);
  PyTuple_SET_ITEM(tuple, 0, _PyLong_FromSsize_t(b));
  PyTuple_SET_ITEM(tuple, 1, _PyLong_FromSsize_t(c));
  result = wrapper(a, tuple);
  Py_DECREF(tuple);
  return result;
}

#define alaqilPY_SSIZESSIZEOBJARGPROC_CLOSURE(wrapper)						\
alaqilINTERN int											\
wrapper##_ssizessizeobjargproc_closure(PyObject *a, Py_ssize_t b, Py_ssize_t c, PyObject *d) {	\
  return alaqilPyBuiltin_ssizessizeobjargproc_closure(wrapper, a, b, c, d);			\
}
alaqilINTERN int
alaqilPyBuiltin_ssizessizeobjargproc_closure(alaqilPyWrapperFunction wrapper, PyObject *a, Py_ssize_t b, Py_ssize_t c, PyObject *d) {
  PyObject *tuple, *resultobj;
  int result;
  tuple = PyTuple_New(d ? 3 : 2);
  assert(tuple);
  PyTuple_SET_ITEM(tuple, 0, _PyLong_FromSsize_t(b));
  PyTuple_SET_ITEM(tuple, 1, _PyLong_FromSsize_t(c));
  if (d) {
    Py_INCREF(d);
    PyTuple_SET_ITEM(tuple, 2, d);
  }
  resultobj = wrapper(a, tuple);
  result = resultobj ? 0 : -1;
  Py_DECREF(tuple);
  Py_XDECREF(resultobj);
  return result;
}

#define alaqilPY_SSIZEARGFUNC_CLOSURE(wrapper)				\
alaqilINTERN PyObject *							\
wrapper##_ssizeargfunc_closure(PyObject *a, Py_ssize_t b) {		\
  return alaqilPyBuiltin_funpack_ssizeargfunc_closure(wrapper, a, b);	\
}
alaqilINTERN PyObject *
alaqilPyBuiltin_funpack_ssizeargfunc_closure(alaqilPyWrapperFunction wrapper, PyObject *a, Py_ssize_t b) {
  PyObject *tuple, *result;
  tuple = PyTuple_New(1);
  assert(tuple);
  PyTuple_SET_ITEM(tuple, 0, _PyLong_FromSsize_t(b));
  result = wrapper(a, tuple);
  Py_DECREF(tuple);
  return result;
}

#define alaqilPY_FUNPACK_SSIZEARGFUNC_CLOSURE(wrapper)			\
alaqilINTERN PyObject *							\
wrapper##_ssizeargfunc_closure(PyObject *a, Py_ssize_t b) {		\
  return alaqilPyBuiltin_ssizeargfunc_closure(wrapper, a, b);		\
}
alaqilINTERN PyObject *
alaqilPyBuiltin_ssizeargfunc_closure(alaqilPyWrapperFunction wrapper, PyObject *a, Py_ssize_t b) {
  PyObject *arg, *result;
  arg = _PyLong_FromSsize_t(b);
  result = wrapper(a, arg);
  Py_DECREF(arg);
  return result;
}

#define alaqilPY_SSIZEOBJARGPROC_CLOSURE(wrapper)					\
alaqilINTERN int									\
wrapper##_ssizeobjargproc_closure(PyObject *a, Py_ssize_t b, PyObject *c) {	\
  return alaqilPyBuiltin_ssizeobjargproc_closure(wrapper, a, b, c);		\
}
alaqilINTERN int
alaqilPyBuiltin_ssizeobjargproc_closure(alaqilPyWrapperFunction wrapper, PyObject *a, Py_ssize_t b, PyObject *c) {
  PyObject *tuple, *resultobj;
  int result;
  tuple = PyTuple_New(2);
  assert(tuple);
  PyTuple_SET_ITEM(tuple, 0, _PyLong_FromSsize_t(b));
  Py_INCREF(c);
  PyTuple_SET_ITEM(tuple, 1, c);
  resultobj = wrapper(a, tuple);
  result = resultobj ? 0 : -1;
  Py_XDECREF(resultobj);
  Py_DECREF(tuple);
  return result;
}

#define alaqilPY_OBJOBJPROC_CLOSURE(wrapper)			\
alaqilINTERN int							\
wrapper##_objobjproc_closure(PyObject *a, PyObject *b) {	\
  return alaqilPyBuiltin_objobjproc_closure(wrapper, a, b);	\
}
alaqilINTERN int
alaqilPyBuiltin_objobjproc_closure(alaqilPyWrapperFunction wrapper, PyObject *a, PyObject *b) {
  int result;
  PyObject *pyresult;
  PyObject *tuple;
  tuple = PyTuple_New(1);
  assert(tuple);
  Py_INCREF(b);
  PyTuple_SET_ITEM(tuple, 0, b);
  pyresult = wrapper(a, tuple);
  result = pyresult ? (PyObject_IsTrue(pyresult) ? 1 : 0) : -1;
  Py_XDECREF(pyresult);
  Py_DECREF(tuple);
  return result;
}

#define alaqilPY_FUNPACK_OBJOBJPROC_CLOSURE(wrapper)			\
alaqilINTERN int								\
wrapper##_objobjproc_closure(PyObject *a, PyObject *b) {		\
  return alaqilPyBuiltin_funpack_objobjproc_closure(wrapper, a, b);	\
}
alaqilINTERN int
alaqilPyBuiltin_funpack_objobjproc_closure(alaqilPyWrapperFunction wrapper, PyObject *a, PyObject *b) {
  int result;
  PyObject *pyresult;
  pyresult = wrapper(a, b);
  result = pyresult ? (PyObject_IsTrue(pyresult) ? 1 : 0) : -1;
  Py_XDECREF(pyresult);
  return result;
}

#define alaqilPY_OBJOBJARGPROC_CLOSURE(wrapper)					\
alaqilINTERN int									\
wrapper##_objobjargproc_closure(PyObject *a, PyObject *b, PyObject *c) {	\
  return alaqilPyBuiltin_objobjargproc_closure(wrapper, a, b, c);			\
}
alaqilINTERN int
alaqilPyBuiltin_objobjargproc_closure(alaqilPyWrapperFunction wrapper, PyObject *a, PyObject *b, PyObject *c) {
  PyObject *tuple, *resultobj;
  int result;
  tuple = PyTuple_New(c ? 2 : 1);
  assert(tuple);
  Py_INCREF(b);
  PyTuple_SET_ITEM(tuple, 0, b);
  if (c) {
    Py_INCREF(c);
    PyTuple_SET_ITEM(tuple, 1, c);
  }
  resultobj = wrapper(a, tuple);
  result = resultobj ? 0 : -1;
  Py_XDECREF(resultobj);
  Py_DECREF(tuple);
  return result;
}

#define alaqilPY_REPRFUNC_CLOSURE(wrapper)		\
alaqilINTERN PyObject *					\
wrapper##_reprfunc_closure(PyObject *a) {		\
  return alaqilPyBuiltin_reprfunc_closure(wrapper, a);	\
}
alaqilINTERN PyObject *
alaqilPyBuiltin_reprfunc_closure(alaqilPyWrapperFunction wrapper, PyObject *a) {
  return wrapper(a, NULL);
}

#define alaqilPY_HASHFUNC_CLOSURE(wrapper)		\
alaqilINTERN Py_hash_t					\
wrapper##_hashfunc_closure(PyObject *a) {		\
  return alaqilPyBuiltin_hashfunc_closure(wrapper, a);	\
}
alaqilINTERN Py_hash_t
alaqilPyBuiltin_hashfunc_closure(alaqilPyWrapperFunction wrapper, PyObject *a) {
  PyObject *pyresult;
  Py_hash_t result;
  pyresult = wrapper(a, NULL);
  if (!pyresult)
    return -1;
  result = alaqil_PyNumber_AsPyHash(pyresult);
  Py_DECREF(pyresult);
  return result;
}

#define alaqilPY_ITERNEXTFUNC_CLOSURE(wrapper)		\
alaqilINTERN PyObject *					\
wrapper##_iternextfunc_closure(PyObject *a) {		\
  return alaqilPyBuiltin_iternextfunc_closure(wrapper, a);\
}
alaqilINTERN PyObject *
alaqilPyBuiltin_iternextfunc_closure(alaqilPyWrapperFunction wrapper, PyObject *a) {
  return wrapper(a, NULL);
}

/* End of callback function macros for use in PyTypeObject */

#ifdef __cplusplus
}
#endif

