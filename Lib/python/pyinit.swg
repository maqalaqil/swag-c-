/* ------------------------------------------------------------
 * The start of the Python initialization function 
 * ------------------------------------------------------------ */

%insert(init) "alaqilinit.swg"

#if defined(alaqilPYTHON_BUILTIN)
%fragment("<stddef.h>"); // For offsetof
#endif

%insert(runtime) %{
#ifdef __cplusplus
extern "C" {
#endif

/* Method creation and docstring support functions */

alaqilINTERN PyMethodDef *alaqil_PythonGetProxyDoc(const char *name);
alaqilINTERN PyObject *alaqil_PyInstanceMethod_New(PyObject *alaqilUNUSEDPARM(self), PyObject *func);
alaqilINTERN PyObject *alaqil_PyStaticMethod_New(PyObject *alaqilUNUSEDPARM(self), PyObject *func);

#ifdef __cplusplus
}
#endif
%}

%init %{

#ifdef __cplusplus
extern "C" {
#endif

/* Python-specific alaqil API */
#define alaqil_newvarlink()                             alaqil_Python_newvarlink()
#define alaqil_addvarlink(p, name, get_attr, set_attr)  alaqil_Python_addvarlink(p, name, get_attr, set_attr)
#define alaqil_InstallConstants(d, constants)           alaqil_Python_InstallConstants(d, constants)
 
/* -----------------------------------------------------------------------------
 * global variable support code.
 * ----------------------------------------------------------------------------- */
 
typedef struct alaqil_globalvar {   
  char       *name;                  /* Name of global variable */
  PyObject *(*get_attr)(void);       /* Return the current value */
  int       (*set_attr)(PyObject *); /* Set the value */
  struct alaqil_globalvar *next;
} alaqil_globalvar;

typedef struct alaqil_varlinkobject {
  PyObject_HEAD
  alaqil_globalvar *vars;
} alaqil_varlinkobject;

alaqilINTERN PyObject *
alaqil_varlink_repr(alaqil_varlinkobject *alaqilUNUSEDPARM(v)) {
#if PY_VERSION_HEX >= 0x03000000
  return PyUnicode_InternFromString("<alaqil global variables>");
#else
  return PyString_FromString("<alaqil global variables>");
#endif
}

alaqilINTERN PyObject *
alaqil_varlink_str(alaqil_varlinkobject *v) {
#if PY_VERSION_HEX >= 0x03000000
  PyObject *str = PyUnicode_InternFromString("(");
  PyObject *tail;
  PyObject *joined;
  alaqil_globalvar *var;
  for (var = v->vars; var; var=var->next) {
    tail = PyUnicode_FromString(var->name);
    joined = PyUnicode_Concat(str, tail);
    Py_DecRef(str);
    Py_DecRef(tail);
    str = joined;
    if (var->next) {
        tail = PyUnicode_InternFromString(", ");
        joined = PyUnicode_Concat(str, tail);
        Py_DecRef(str);
        Py_DecRef(tail);
        str = joined;
    }
  }
  tail = PyUnicode_InternFromString(")");
  joined = PyUnicode_Concat(str, tail);
  Py_DecRef(str);
  Py_DecRef(tail);
  str = joined;
#else
  PyObject *str = PyString_FromString("(");
  alaqil_globalvar *var;
  for (var = v->vars; var; var=var->next) {
    PyString_ConcatAndDel(&str,PyString_FromString(var->name));
    if (var->next) PyString_ConcatAndDel(&str,PyString_FromString(", "));
  }
  PyString_ConcatAndDel(&str,PyString_FromString(")"));
#endif
  return str;
}

alaqilINTERN void
alaqil_varlink_dealloc(alaqil_varlinkobject *v) {
  alaqil_globalvar *var = v->vars;
  while (var) {
    alaqil_globalvar *n = var->next;
    free(var->name);
    free(var);
    var = n;
  }
}

alaqilINTERN PyObject *
alaqil_varlink_getattr(alaqil_varlinkobject *v, char *n) {
  PyObject *res = NULL;
  alaqil_globalvar *var = v->vars;
  while (var) {
    if (strcmp(var->name,n) == 0) {
      res = (*var->get_attr)();
      break;
    }
    var = var->next;
  }
  if (res == NULL && !PyErr_Occurred()) {
    PyErr_Format(PyExc_AttributeError, "Unknown C global variable '%s'", n);
  }
  return res;
}

alaqilINTERN int
alaqil_varlink_setattr(alaqil_varlinkobject *v, char *n, PyObject *p) {
  int res = 1;
  alaqil_globalvar *var = v->vars;
  while (var) {
    if (strcmp(var->name,n) == 0) {
      res = (*var->set_attr)(p);
      break;
    }
    var = var->next;
  }
  if (res == 1 && !PyErr_Occurred()) {
    PyErr_Format(PyExc_AttributeError, "Unknown C global variable '%s'", n);
  }
  return res;
}

alaqilINTERN PyTypeObject*
alaqil_varlink_type(void) {
  static char varlink__doc__[] = "alaqil var link object";
  static PyTypeObject varlink_type;
  static int type_init = 0;
  if (!type_init) {
    const PyTypeObject tmp = {
#if PY_VERSION_HEX >= 0x03000000
      PyVarObject_HEAD_INIT(NULL, 0)
#else
      PyObject_HEAD_INIT(NULL)
      0,                                  /* ob_size */
#endif
      "alaqilvarlink",                      /* tp_name */
      sizeof(alaqil_varlinkobject),         /* tp_basicsize */
      0,                                  /* tp_itemsize */
      (destructor) alaqil_varlink_dealloc,  /* tp_dealloc */
      0,                                  /* tp_print */
      (getattrfunc) alaqil_varlink_getattr, /* tp_getattr */
      (setattrfunc) alaqil_varlink_setattr, /* tp_setattr */
      0,                                  /* tp_compare */
      (reprfunc) alaqil_varlink_repr,       /* tp_repr */
      0,                                  /* tp_as_number */
      0,                                  /* tp_as_sequence */
      0,                                  /* tp_as_mapping */
      0,                                  /* tp_hash */
      0,                                  /* tp_call */
      (reprfunc) alaqil_varlink_str,        /* tp_str */
      0,                                  /* tp_getattro */
      0,                                  /* tp_setattro */
      0,                                  /* tp_as_buffer */
      0,                                  /* tp_flags */
      varlink__doc__,                     /* tp_doc */
      0,                                  /* tp_traverse */
      0,                                  /* tp_clear */
      0,                                  /* tp_richcompare */
      0,                                  /* tp_weaklistoffset */
      0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0, /* tp_iter -> tp_weaklist */
      0,                                  /* tp_del */
      0,                                  /* tp_version_tag */
#if PY_VERSION_HEX >= 0x03040000
      0,                                  /* tp_finalize */
#endif
#ifdef COUNT_ALLOCS
      0,                                  /* tp_allocs */
      0,                                  /* tp_frees */
      0,                                  /* tp_maxalloc */
      0,                                  /* tp_prev */
      0                                   /* tp_next */
#endif
    };
    varlink_type = tmp;
    type_init = 1;
    if (PyType_Ready(&varlink_type) < 0)
      return NULL;
  }
  return &varlink_type;
}

/* Create a variable linking object for use later */
alaqilINTERN PyObject *
alaqil_Python_newvarlink(void) {
  alaqil_varlinkobject *result = PyObject_NEW(alaqil_varlinkobject, alaqil_varlink_type());
  if (result) {
    result->vars = 0;
  }
  return ((PyObject*) result);
}

alaqilINTERN void 
alaqil_Python_addvarlink(PyObject *p, const char *name, PyObject *(*get_attr)(void), int (*set_attr)(PyObject *p)) {
  alaqil_varlinkobject *v = (alaqil_varlinkobject *) p;
  alaqil_globalvar *gv = (alaqil_globalvar *) malloc(sizeof(alaqil_globalvar));
  if (gv) {
    size_t size = strlen(name)+1;
    gv->name = (char *)malloc(size);
    if (gv->name) {
      memcpy(gv->name, name, size);
      gv->get_attr = get_attr;
      gv->set_attr = set_attr;
      gv->next = v->vars;
    }
  }
  v->vars = gv;
}

alaqilINTERN PyObject *
alaqil_globals(void) {
  static PyObject *globals = 0;
  if (!globals) {
    globals = alaqil_newvarlink();
  }
  return globals;
}

/* -----------------------------------------------------------------------------
 * constants/methods manipulation
 * ----------------------------------------------------------------------------- */

/* Install Constants */
alaqilINTERN void
alaqil_Python_InstallConstants(PyObject *d, alaqil_const_info constants[]) {
  PyObject *obj = 0;
  size_t i;
  for (i = 0; constants[i].type; ++i) {
    switch(constants[i].type) {
    case alaqil_PY_POINTER:
      obj = alaqil_InternalNewPointerObj(constants[i].pvalue, *(constants[i]).ptype,0);
      break;
    case alaqil_PY_BINARY:
      obj = alaqil_NewPackedObj(constants[i].pvalue, constants[i].lvalue, *(constants[i].ptype));
      break;
    default:
      obj = 0;
      break;
    }
    if (obj) {
      PyDict_SetItemString(d, constants[i].name, obj);
      Py_DECREF(obj);
    }
  }
}

/* -----------------------------------------------------------------------------*/
/* Fix alaqilMethods to carry the callback ptrs when needed */
/* -----------------------------------------------------------------------------*/

alaqilINTERN void
alaqil_Python_FixMethods(PyMethodDef *methods,
		       alaqil_const_info *const_table,
		       alaqil_type_info **types,
		       alaqil_type_info **types_initial) {
  size_t i;
  for (i = 0; methods[i].ml_name; ++i) {
    const char *c = methods[i].ml_doc;
    if (!c) continue;
    c = strstr(c, "alaqil_ptr: ");
    if (c) {
      int j;
      alaqil_const_info *ci = 0;
      const char *name = c + 10;
      for (j = 0; const_table[j].type; ++j) {
	if (strncmp(const_table[j].name, name, 
		    strlen(const_table[j].name)) == 0) {
	  ci = &(const_table[j]);
	  break;
	}
      }
      if (ci) {
	void *ptr = (ci->type == alaqil_PY_POINTER) ? ci->pvalue : 0;
	if (ptr) {
	  size_t shift = (ci->ptype) - types;
	  alaqil_type_info *ty = types_initial[shift];
	  size_t ldoc = (c - methods[i].ml_doc);
	  size_t lptr = strlen(ty->name)+2*sizeof(void*)+2;
	  char *ndoc = (char*)malloc(ldoc + lptr + 10);
	  if (ndoc) {
	    char *buff = ndoc;
	    memcpy(buff, methods[i].ml_doc, ldoc);
	    buff += ldoc;
	    memcpy(buff, "alaqil_ptr: ", 10);
	    buff += 10;
	    alaqil_PackVoidPtr(buff, ptr, ty->name, lptr);
	    methods[i].ml_doc = ndoc;
	  }
	}
      }
    }
  }
} 

/* -----------------------------------------------------------------------------
 * Method creation and docstring support functions
 * ----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
 * Function to find the method definition with the correct docstring for the
 * proxy module as opposed to the low-level API
 * ----------------------------------------------------------------------------- */

alaqilINTERN PyMethodDef *alaqil_PythonGetProxyDoc(const char *name) {
  /* Find the function in the modified method table */
  size_t offset = 0;
  int found = 0;
  while (alaqilMethods_proxydocs[offset].ml_meth != NULL) {
    if (strcmp(alaqilMethods_proxydocs[offset].ml_name, name) == 0) {
      found = 1;
      break;
    }
    offset++;
  }
  /* Use the copy with the modified docstring if available */
  return found ? &alaqilMethods_proxydocs[offset] : NULL;
}

/* -----------------------------------------------------------------------------
 * Wrapper of PyInstanceMethod_New() used in Python 3
 * It is exported to the generated module, used for -fastproxy
 * ----------------------------------------------------------------------------- */

alaqilINTERN PyObject *alaqil_PyInstanceMethod_New(PyObject *alaqilUNUSEDPARM(self), PyObject *func) {
  if (PyCFunction_Check(func)) {
    PyCFunctionObject *funcobj = (PyCFunctionObject *)func;
    PyMethodDef *ml = alaqil_PythonGetProxyDoc(funcobj->m_ml->ml_name);
    if (ml)
      func = PyCFunction_NewEx(ml, funcobj->m_self, funcobj->m_module);
  }
#if PY_VERSION_HEX >= 0x03000000
  return PyInstanceMethod_New(func);
#else
  return PyMethod_New(func, NULL, NULL);
#endif
}

/* -----------------------------------------------------------------------------
 * Wrapper of PyStaticMethod_New()
 * It is exported to the generated module, used for -fastproxy
 * ----------------------------------------------------------------------------- */

alaqilINTERN PyObject *alaqil_PyStaticMethod_New(PyObject *alaqilUNUSEDPARM(self), PyObject *func) {
  if (PyCFunction_Check(func)) {
    PyCFunctionObject *funcobj = (PyCFunctionObject *)func;
    PyMethodDef *ml = alaqil_PythonGetProxyDoc(funcobj->m_ml->ml_name);
    if (ml)
      func = PyCFunction_NewEx(ml, funcobj->m_self, funcobj->m_module);
  }
  return PyStaticMethod_New(func);
}

#ifdef __cplusplus
}
#endif

/* -----------------------------------------------------------------------------*
 *  Partial Init method
 * -----------------------------------------------------------------------------*/

#ifdef __cplusplus
extern "C"
#endif

alaqilEXPORT 
#if PY_VERSION_HEX >= 0x03000000
  PyObject*
#else
  void
#endif
alaqil_init(void) {
  PyObject *m, *d, *md, *globals;

#if PY_VERSION_HEX >= 0x03000000
  static struct PyModuleDef alaqil_module = {
    PyModuleDef_HEAD_INIT,
    alaqil_name,
    NULL,
    -1,
    alaqilMethods,
    NULL,
    NULL,
    NULL,
    NULL
  };
#endif

#if defined(alaqilPYTHON_BUILTIN)
  static alaqilPyClientData alaqilPyObject_clientdata = {0, 0, 0, 0, 0, 0, 0};
  static PyGetSetDef this_getset_def = {
    (char *)"this", &alaqilPyBuiltin_ThisClosure, NULL, NULL, NULL
  };
  static alaqilPyGetSet thisown_getset_closure = {
    alaqilPyObject_own,
    alaqilPyObject_own
  };
  static PyGetSetDef thisown_getset_def = {
    (char *)"thisown", alaqilPyBuiltin_GetterClosure, alaqilPyBuiltin_SetterClosure, NULL, &thisown_getset_closure
  };
  PyTypeObject *builtin_pytype;
  int builtin_base_count;
  alaqil_type_info *builtin_basetype;
  PyObject *tuple;
  PyGetSetDescrObject *static_getset;
  PyTypeObject *metatype;
  PyTypeObject *alaqilpyobject;
  alaqilPyClientData *cd;
  PyObject *public_interface, *public_symbol;
  PyObject *this_descr;
  PyObject *thisown_descr;
  PyObject *self = 0;
  int i;

  (void)builtin_pytype;
  (void)builtin_base_count;
  (void)builtin_basetype;
  (void)tuple;
  (void)static_getset;
  (void)self;

  /* Metaclass is used to implement static member variables */
  metatype = alaqilPyObjectType();
  assert(metatype);
#endif

  (void)globals;

  /* Create singletons now to avoid potential deadlocks with multi-threaded usage after module initialization */
  alaqil_This();
  alaqil_Python_TypeCache();
  alaqilPyPacked_type();
#ifndef alaqilPYTHON_BUILTIN
  alaqilPyObject_type();
#endif

  /* Fix alaqilMethods to carry the callback ptrs when needed */
  alaqil_Python_FixMethods(alaqilMethods, alaqil_const_table, alaqil_types, alaqil_type_initial);

#if PY_VERSION_HEX >= 0x03000000
  m = PyModule_Create(&alaqil_module);
#else
  m = Py_InitModule(alaqil_name, alaqilMethods);
#endif

  md = d = PyModule_GetDict(m);
  (void)md;

  alaqil_InitializeModule(0);

#ifdef alaqilPYTHON_BUILTIN
  alaqilpyobject = alaqilPyObject_TypeOnce();

  alaqilPyObject_stype = alaqil_MangledTypeQuery("_p_alaqilPyObject");
  assert(alaqilPyObject_stype);
  cd = (alaqilPyClientData*) alaqilPyObject_stype->clientdata;
  if (!cd) {
    alaqilPyObject_stype->clientdata = &alaqilPyObject_clientdata;
    alaqilPyObject_clientdata.pytype = alaqilpyobject;
  } else if (alaqilpyobject->tp_basicsize != cd->pytype->tp_basicsize) {
    PyErr_SetString(PyExc_RuntimeError, "Import error: attempted to load two incompatible alaqil-generated modules.");
# if PY_VERSION_HEX >= 0x03000000
    return NULL;
# else
    return;
# endif
  }

  /* All objects have a 'this' attribute */
  this_descr = PyDescr_NewGetSet(alaqilPyObject_type(), &this_getset_def);
  (void)this_descr;

  /* All objects have a 'thisown' attribute */
  thisown_descr = PyDescr_NewGetSet(alaqilPyObject_type(), &thisown_getset_def);
  (void)thisown_descr;

  public_interface = PyList_New(0);
  public_symbol = 0;
  (void)public_symbol;

  PyDict_SetItemString(md, "__all__", public_interface);
  Py_DECREF(public_interface);
  for (i = 0; alaqilMethods[i].ml_name != NULL; ++i)
    alaqilPyBuiltin_AddPublicSymbol(public_interface, alaqilMethods[i].ml_name);
  for (i = 0; alaqil_const_table[i].name != 0; ++i)
    alaqilPyBuiltin_AddPublicSymbol(public_interface, alaqil_const_table[i].name);
#endif

  alaqil_InstallConstants(d,alaqil_const_table);
%}

