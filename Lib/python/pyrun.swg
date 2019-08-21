/* -----------------------------------------------------------------------------
 * pyrun.swg
 *
 * This file contains the runtime support for Python modules
 * and includes code for managing global variables and pointer
 * type checking.
 *
 * ----------------------------------------------------------------------------- */

#if PY_VERSION_HEX < 0x02070000 /* 2.7.0 */
# error "This version of alaqil only supports Python >= 2.7"
#endif

#if PY_VERSION_HEX >= 0x03000000 && PY_VERSION_HEX < 0x03020000
# error "This version of alaqil only supports Python 3 >= 3.2"
#endif

/* Common alaqil API */

/* for raw pointers */
#define alaqil_Python_ConvertPtr(obj, pptr, type, flags)  alaqil_Python_ConvertPtrAndOwn(obj, pptr, type, flags, 0)
#define alaqil_ConvertPtr(obj, pptr, type, flags)         alaqil_Python_ConvertPtr(obj, pptr, type, flags)
#define alaqil_ConvertPtrAndOwn(obj,pptr,type,flags,own)  alaqil_Python_ConvertPtrAndOwn(obj, pptr, type, flags, own)

#ifdef alaqilPYTHON_BUILTIN
#define alaqil_NewPointerObj(ptr, type, flags)            alaqil_Python_NewPointerObj(self, ptr, type, flags)
#else
#define alaqil_NewPointerObj(ptr, type, flags)            alaqil_Python_NewPointerObj(NULL, ptr, type, flags)
#endif

#define alaqil_InternalNewPointerObj(ptr, type, flags)	alaqil_Python_NewPointerObj(NULL, ptr, type, flags)

#define alaqil_CheckImplicit(ty)                          alaqil_Python_CheckImplicit(ty) 
#define alaqil_AcquirePtr(ptr, src)                       alaqil_Python_AcquirePtr(ptr, src)
#define alaqil_owntype                                    int

/* for raw packed data */
#define alaqil_ConvertPacked(obj, ptr, sz, ty)            alaqil_Python_ConvertPacked(obj, ptr, sz, ty)
#define alaqil_NewPackedObj(ptr, sz, type)                alaqil_Python_NewPackedObj(ptr, sz, type)

/* for class or struct pointers */
#define alaqil_ConvertInstance(obj, pptr, type, flags)    alaqil_ConvertPtr(obj, pptr, type, flags)
#define alaqil_NewInstanceObj(ptr, type, flags)           alaqil_NewPointerObj(ptr, type, flags)

/* for C or C++ function pointers */
#define alaqil_ConvertFunctionPtr(obj, pptr, type)        alaqil_Python_ConvertFunctionPtr(obj, pptr, type)
#define alaqil_NewFunctionPtrObj(ptr, type)               alaqil_Python_NewPointerObj(NULL, ptr, type, 0)

/* for C++ member pointers, ie, member methods */
#define alaqil_ConvertMember(obj, ptr, sz, ty)            alaqil_Python_ConvertPacked(obj, ptr, sz, ty)
#define alaqil_NewMemberObj(ptr, sz, type)                alaqil_Python_NewPackedObj(ptr, sz, type)


/* Runtime API */

#define alaqil_GetModule(clientdata)                      alaqil_Python_GetModule(clientdata)
#define alaqil_SetModule(clientdata, pointer)             alaqil_Python_SetModule(pointer)
#define alaqil_NewClientData(obj)                         alaqilPyClientData_New(obj)

#define alaqil_SetErrorObj                                alaqil_Python_SetErrorObj                            
#define alaqil_SetErrorMsg                        	alaqil_Python_SetErrorMsg				   
#define alaqil_ErrorType(code)                    	alaqil_Python_ErrorType(code)                        
#define alaqil_Error(code, msg)            		alaqil_Python_SetErrorMsg(alaqil_ErrorType(code), msg) 
#define alaqil_fail                        		goto fail					   


/* Runtime API implementation */

/* Error manipulation */

alaqilINTERN void 
alaqil_Python_SetErrorObj(PyObject *errtype, PyObject *obj) {
  alaqil_PYTHON_THREAD_BEGIN_BLOCK; 
  PyErr_SetObject(errtype, obj);
  Py_DECREF(obj);
  alaqil_PYTHON_THREAD_END_BLOCK;
}

alaqilINTERN void 
alaqil_Python_SetErrorMsg(PyObject *errtype, const char *msg) {
  alaqil_PYTHON_THREAD_BEGIN_BLOCK;
  PyErr_SetString(errtype, msg);
  alaqil_PYTHON_THREAD_END_BLOCK;
}

#define alaqil_Python_Raise(obj, type, desc)  alaqil_Python_SetErrorObj(alaqil_Python_ExceptionType(desc), obj)

/* Set a constant value */

#if defined(alaqilPYTHON_BUILTIN)

alaqilINTERN void
alaqilPyBuiltin_AddPublicSymbol(PyObject *seq, const char *key) {
  PyObject *s = PyString_InternFromString(key);
  PyList_Append(seq, s);
  Py_DECREF(s);
}

alaqilINTERN void
alaqil_Python_SetConstant(PyObject *d, PyObject *public_interface, const char *name, PyObject *obj) {   
  PyDict_SetItemString(d, name, obj);
  Py_DECREF(obj);
  if (public_interface)
    alaqilPyBuiltin_AddPublicSymbol(public_interface, name);
}

#else

alaqilINTERN void
alaqil_Python_SetConstant(PyObject *d, const char *name, PyObject *obj) {   
  PyDict_SetItemString(d, name, obj);
  Py_DECREF(obj);                            
}

#endif

/* Append a value to the result obj */

alaqilINTERN PyObject*
alaqil_Python_AppendOutput(PyObject* result, PyObject* obj) {
  if (!result) {
    result = obj;
  } else if (result == Py_None) {
    Py_DECREF(result);
    result = obj;
  } else {
    if (!PyList_Check(result)) {
      PyObject *o2 = result;
      result = PyList_New(1);
      PyList_SetItem(result, 0, o2);
    }
    PyList_Append(result,obj);
    Py_DECREF(obj);
  }
  return result;
}

/* Unpack the argument tuple */

alaqilINTERN Py_ssize_t
alaqil_Python_UnpackTuple(PyObject *args, const char *name, Py_ssize_t min, Py_ssize_t max, PyObject **objs)
{
  if (!args) {
    if (!min && !max) {
      return 1;
    } else {
      PyErr_Format(PyExc_TypeError, "%s expected %s%d arguments, got none", 
		   name, (min == max ? "" : "at least "), (int)min);
      return 0;
    }
  }  
  if (!PyTuple_Check(args)) {
    if (min <= 1 && max >= 1) {
      Py_ssize_t i;
      objs[0] = args;
      for (i = 1; i < max; ++i) {
	objs[i] = 0;
      }
      return 2;
    }
    PyErr_SetString(PyExc_SystemError, "UnpackTuple() argument list is not a tuple");
    return 0;
  } else {
    Py_ssize_t l = PyTuple_GET_SIZE(args);
    if (l < min) {
      PyErr_Format(PyExc_TypeError, "%s expected %s%d arguments, got %d", 
		   name, (min == max ? "" : "at least "), (int)min, (int)l);
      return 0;
    } else if (l > max) {
      PyErr_Format(PyExc_TypeError, "%s expected %s%d arguments, got %d", 
		   name, (min == max ? "" : "at most "), (int)max, (int)l);
      return 0;
    } else {
      Py_ssize_t i;
      for (i = 0; i < l; ++i) {
	objs[i] = PyTuple_GET_ITEM(args, i);
      }
      for (; l < max; ++l) {
	objs[l] = 0;
      }
      return i + 1;
    }    
  }
}

/* A functor is a function object with one single object argument */
#define alaqil_Python_CallFunctor(functor, obj)	        PyObject_CallFunction(functor, (char *)"O", obj);

/*
  Helper for static pointer initialization for both C and C++ code, for example
  static PyObject *alaqil_STATIC_POINTER(MyVar) = NewSomething(...);
*/
#ifdef __cplusplus
#define alaqil_STATIC_POINTER(var)  var
#else
#define alaqil_STATIC_POINTER(var)  var = 0; if (!var) var
#endif

/* -----------------------------------------------------------------------------
 * Pointer declarations
 * ----------------------------------------------------------------------------- */

/* Flags for new pointer objects */
#define alaqil_POINTER_NOSHADOW       (alaqil_POINTER_OWN      << 1)
#define alaqil_POINTER_NEW            (alaqil_POINTER_NOSHADOW | alaqil_POINTER_OWN)

#define alaqil_POINTER_IMPLICIT_CONV  (alaqil_POINTER_DISOWN   << 1)

#define alaqil_BUILTIN_TP_INIT	    (alaqil_POINTER_OWN << 2)
#define alaqil_BUILTIN_INIT	    (alaqil_BUILTIN_TP_INIT | alaqil_POINTER_OWN)

#ifdef __cplusplus
extern "C" {
#endif

/* The python void return value */

alaqilRUNTIMEINLINE PyObject * 
alaqil_Py_Void(void)
{
  PyObject *none = Py_None;
  Py_INCREF(none);
  return none;
}

/* alaqilPyClientData */

typedef struct {
  PyObject *klass;
  PyObject *newraw;
  PyObject *newargs;
  PyObject *destroy;
  int delargs;
  int implicitconv;
  PyTypeObject *pytype;
} alaqilPyClientData;

alaqilRUNTIMEINLINE int 
alaqil_Python_CheckImplicit(alaqil_type_info *ty)
{
  alaqilPyClientData *data = (alaqilPyClientData *)ty->clientdata;
  int fail = data ? data->implicitconv : 0;
  if (fail)
    PyErr_SetString(PyExc_TypeError, "Implicit conversion is prohibited for explicit constructors.");
  return fail;
}

alaqilRUNTIMEINLINE PyObject *
alaqil_Python_ExceptionType(alaqil_type_info *desc) {
  alaqilPyClientData *data = desc ? (alaqilPyClientData *) desc->clientdata : 0;
  PyObject *klass = data ? data->klass : 0;
  return (klass ? klass : PyExc_RuntimeError);
}


alaqilRUNTIME alaqilPyClientData * 
alaqilPyClientData_New(PyObject* obj)
{
  if (!obj) {
    return 0;
  } else {
    alaqilPyClientData *data = (alaqilPyClientData *)malloc(sizeof(alaqilPyClientData));
    /* the klass element */
    data->klass = obj;
    Py_INCREF(data->klass);
    /* the newraw method and newargs arguments used to create a new raw instance */
    if (PyClass_Check(obj)) {
      data->newraw = 0;
      data->newargs = obj;
      Py_INCREF(obj);
    } else {
      data->newraw = PyObject_GetAttrString(data->klass, "__new__");
      if (data->newraw) {
	Py_INCREF(data->newraw);
	data->newargs = PyTuple_New(1);
	PyTuple_SetItem(data->newargs, 0, obj);
      } else {
	data->newargs = obj;
      }
      Py_INCREF(data->newargs);
    }
    /* the destroy method, aka as the C++ delete method */
    data->destroy = PyObject_GetAttrString(data->klass, "__alaqil_destroy__");
    if (PyErr_Occurred()) {
      PyErr_Clear();
      data->destroy = 0;
    }
    if (data->destroy) {
      int flags;
      Py_INCREF(data->destroy);
      flags = PyCFunction_GET_FLAGS(data->destroy);
      data->delargs = !(flags & (METH_O));
    } else {
      data->delargs = 0;
    }
    data->implicitconv = 0;
    data->pytype = 0;
    return data;
  }
}

alaqilRUNTIME void 
alaqilPyClientData_Del(alaqilPyClientData *data) {
  Py_XDECREF(data->newraw);
  Py_XDECREF(data->newargs);
  Py_XDECREF(data->destroy);
}

/* =============== alaqilPyObject =====================*/

typedef struct {
  PyObject_HEAD
  void *ptr;
  alaqil_type_info *ty;
  int own;
  PyObject *next;
#ifdef alaqilPYTHON_BUILTIN
  PyObject *dict;
#endif
} alaqilPyObject;


#ifdef alaqilPYTHON_BUILTIN

alaqilRUNTIME PyObject *
alaqilPyObject_get___dict__(PyObject *v, PyObject *alaqilUNUSEDPARM(args))
{
  alaqilPyObject *sobj = (alaqilPyObject *)v;

  if (!sobj->dict)
    sobj->dict = PyDict_New();

  Py_INCREF(sobj->dict);
  return sobj->dict;
}

#endif

alaqilRUNTIME PyObject *
alaqilPyObject_long(alaqilPyObject *v)
{
  return PyLong_FromVoidPtr(v->ptr);
}

alaqilRUNTIME PyObject *
alaqilPyObject_format(const char* fmt, alaqilPyObject *v)
{
  PyObject *res = NULL;
  PyObject *args = PyTuple_New(1);
  if (args) {
    if (PyTuple_SetItem(args, 0, alaqilPyObject_long(v)) == 0) {
      PyObject *ofmt = alaqil_Python_str_FromChar(fmt);
      if (ofmt) {
#if PY_VERSION_HEX >= 0x03000000
	res = PyUnicode_Format(ofmt,args);
#else
	res = PyString_Format(ofmt,args);
#endif
	Py_DECREF(ofmt);
      }
      Py_DECREF(args);
    }
  }
  return res;
}

alaqilRUNTIME PyObject *
alaqilPyObject_oct(alaqilPyObject *v)
{
  return alaqilPyObject_format("%o",v);
}

alaqilRUNTIME PyObject *
alaqilPyObject_hex(alaqilPyObject *v)
{
  return alaqilPyObject_format("%x",v);
}

alaqilRUNTIME PyObject *
alaqilPyObject_repr(alaqilPyObject *v)
{
  const char *name = alaqil_TypePrettyName(v->ty);
  PyObject *repr = alaqil_Python_str_FromFormat("<alaqil Object of type '%s' at %p>", (name ? name : "unknown"), (void *)v);
  if (v->next) {
    PyObject *nrep = alaqilPyObject_repr((alaqilPyObject *)v->next);
# if PY_VERSION_HEX >= 0x03000000
    PyObject *joined = PyUnicode_Concat(repr, nrep);
    Py_DecRef(repr);
    Py_DecRef(nrep);
    repr = joined;
# else
    PyString_ConcatAndDel(&repr,nrep);
# endif
  }
  return repr;  
}

/* We need a version taking two PyObject* parameters so it's a valid
 * PyCFunction to use in alaqilobject_methods[]. */
alaqilRUNTIME PyObject *
alaqilPyObject_repr2(PyObject *v, PyObject *alaqilUNUSEDPARM(args))
{
  return alaqilPyObject_repr((alaqilPyObject*)v);
}

alaqilRUNTIME int
alaqilPyObject_compare(alaqilPyObject *v, alaqilPyObject *w)
{
  void *i = v->ptr;
  void *j = w->ptr;
  return (i < j) ? -1 : ((i > j) ? 1 : 0);
}

/* Added for Python 3.x, would it also be useful for Python 2.x? */
alaqilRUNTIME PyObject*
alaqilPyObject_richcompare(alaqilPyObject *v, alaqilPyObject *w, int op)
{
  PyObject* res;
  if( op != Py_EQ && op != Py_NE ) {
    Py_INCREF(Py_NotImplemented);
    return Py_NotImplemented;
  }
  res = PyBool_FromLong( (alaqilPyObject_compare(v, w)==0) == (op == Py_EQ) ? 1 : 0);
  return res;  
}


alaqilRUNTIME PyTypeObject* alaqilPyObject_TypeOnce(void);

#ifdef alaqilPYTHON_BUILTIN
static alaqil_type_info *alaqilPyObject_stype = 0;
alaqilRUNTIME PyTypeObject*
alaqilPyObject_type(void) {
    alaqilPyClientData *cd;
    assert(alaqilPyObject_stype);
    cd = (alaqilPyClientData*) alaqilPyObject_stype->clientdata;
    assert(cd);
    assert(cd->pytype);
    return cd->pytype;
}
#else
alaqilRUNTIME PyTypeObject*
alaqilPyObject_type(void) {
  static PyTypeObject *alaqil_STATIC_POINTER(type) = alaqilPyObject_TypeOnce();
  return type;
}
#endif

alaqilRUNTIMEINLINE int
alaqilPyObject_Check(PyObject *op) {
#ifdef alaqilPYTHON_BUILTIN
  PyTypeObject *target_tp = alaqilPyObject_type();
  if (PyType_IsSubtype(op->ob_type, target_tp))
    return 1;
  return (strcmp(op->ob_type->tp_name, "alaqilPyObject") == 0);
#else
  return (Py_TYPE(op) == alaqilPyObject_type())
    || (strcmp(Py_TYPE(op)->tp_name,"alaqilPyObject") == 0);
#endif
}

alaqilRUNTIME PyObject *
alaqilPyObject_New(void *ptr, alaqil_type_info *ty, int own);

alaqilRUNTIME void
alaqilPyObject_dealloc(PyObject *v)
{
  alaqilPyObject *sobj = (alaqilPyObject *) v;
  PyObject *next = sobj->next;
  if (sobj->own == alaqil_POINTER_OWN) {
    alaqil_type_info *ty = sobj->ty;
    alaqilPyClientData *data = ty ? (alaqilPyClientData *) ty->clientdata : 0;
    PyObject *destroy = data ? data->destroy : 0;
    if (destroy) {
      /* destroy is always a VARARGS method */
      PyObject *res;

      /* PyObject_CallFunction() has the potential to silently drop
         the active exception.  In cases of unnamed temporary
         variable or where we just finished iterating over a generator
         StopIteration will be active right now, and this needs to
         remain true upon return from alaqilPyObject_dealloc.  So save
         and restore. */
      
      PyObject *type = NULL, *value = NULL, *traceback = NULL;
      PyErr_Fetch(&type, &value, &traceback);

      if (data->delargs) {
        /* we need to create a temporary object to carry the destroy operation */
        PyObject *tmp = alaqilPyObject_New(sobj->ptr, ty, 0);
        res = alaqil_Python_CallFunctor(destroy, tmp);
        Py_DECREF(tmp);
      } else {
        PyCFunction meth = PyCFunction_GET_FUNCTION(destroy);
        PyObject *mself = PyCFunction_GET_SELF(destroy);
        res = ((*meth)(mself, v));
      }
      if (!res)
        PyErr_WriteUnraisable(destroy);

      PyErr_Restore(type, value, traceback);

      Py_XDECREF(res);
    } 
#if !defined(alaqil_PYTHON_SILENT_MEMLEAK)
    else {
      const char *name = alaqil_TypePrettyName(ty);
      printf("alaqil/python detected a memory leak of type '%s', no destructor found.\n", (name ? name : "unknown"));
    }
#endif
  } 
  Py_XDECREF(next);
  PyObject_DEL(v);
}

alaqilRUNTIME PyObject* 
alaqilPyObject_append(PyObject* v, PyObject* next)
{
  alaqilPyObject *sobj = (alaqilPyObject *) v;
  if (!alaqilPyObject_Check(next)) {
    PyErr_SetString(PyExc_TypeError, "Attempt to append a non alaqilPyObject");
    return NULL;
  }
  sobj->next = next;
  Py_INCREF(next);
  return alaqil_Py_Void();
}

alaqilRUNTIME PyObject* 
alaqilPyObject_next(PyObject* v, PyObject *alaqilUNUSEDPARM(args))
{
  alaqilPyObject *sobj = (alaqilPyObject *) v;
  if (sobj->next) {    
    Py_INCREF(sobj->next);
    return sobj->next;
  } else {
    return alaqil_Py_Void();
  }
}

alaqilINTERN PyObject*
alaqilPyObject_disown(PyObject* v, PyObject *alaqilUNUSEDPARM(args))
{
  alaqilPyObject *sobj = (alaqilPyObject *)v;
  sobj->own = 0;
  return alaqil_Py_Void();
}

alaqilINTERN PyObject*
alaqilPyObject_acquire(PyObject* v, PyObject *alaqilUNUSEDPARM(args))
{
  alaqilPyObject *sobj = (alaqilPyObject *)v;
  sobj->own = alaqil_POINTER_OWN;
  return alaqil_Py_Void();
}

alaqilINTERN PyObject*
alaqilPyObject_own(PyObject *v, PyObject *args)
{
  PyObject *val = 0;
  if (!PyArg_UnpackTuple(args, "own", 0, 1, &val)) {
    return NULL;
  } else {
    alaqilPyObject *sobj = (alaqilPyObject *)v;
    PyObject *obj = PyBool_FromLong(sobj->own);
    if (val) {
      if (PyObject_IsTrue(val)) {
        alaqilPyObject_acquire(v,args);
      } else {
        alaqilPyObject_disown(v,args);
      }
    } 
    return obj;
  }
}

static PyMethodDef
alaqilobject_methods[] = {
  {"disown",  alaqilPyObject_disown,  METH_NOARGS,  "releases ownership of the pointer"},
  {"acquire", alaqilPyObject_acquire, METH_NOARGS,  "acquires ownership of the pointer"},
  {"own",     alaqilPyObject_own,     METH_VARARGS, "returns/sets ownership of the pointer"},
  {"append",  alaqilPyObject_append,  METH_O,       "appends another 'this' object"},
  {"next",    alaqilPyObject_next,    METH_NOARGS,  "returns the next 'this' object"},
  {"__repr__",alaqilPyObject_repr2,   METH_NOARGS,  "returns object representation"},
  {0, 0, 0, 0}  
};

alaqilRUNTIME PyTypeObject*
alaqilPyObject_TypeOnce(void) {
  static char alaqilobject_doc[] = "alaqil object carries a C/C++ instance pointer";

  static PyNumberMethods alaqilPyObject_as_number = {
    (binaryfunc)0, /*nb_add*/
    (binaryfunc)0, /*nb_subtract*/
    (binaryfunc)0, /*nb_multiply*/
    /* nb_divide removed in Python 3 */
#if PY_VERSION_HEX < 0x03000000
    (binaryfunc)0, /*nb_divide*/
#endif
    (binaryfunc)0, /*nb_remainder*/
    (binaryfunc)0, /*nb_divmod*/
    (ternaryfunc)0,/*nb_power*/
    (unaryfunc)0,  /*nb_negative*/
    (unaryfunc)0,  /*nb_positive*/
    (unaryfunc)0,  /*nb_absolute*/
    (inquiry)0,    /*nb_nonzero*/
    0,		   /*nb_invert*/
    0,		   /*nb_lshift*/
    0,		   /*nb_rshift*/
    0,		   /*nb_and*/
    0,		   /*nb_xor*/
    0,		   /*nb_or*/
#if PY_VERSION_HEX < 0x03000000
    0,   /*nb_coerce*/
#endif
    (unaryfunc)alaqilPyObject_long, /*nb_int*/
#if PY_VERSION_HEX < 0x03000000
    (unaryfunc)alaqilPyObject_long, /*nb_long*/
#else
    0, /*nb_reserved*/
#endif
    (unaryfunc)0,                 /*nb_float*/
#if PY_VERSION_HEX < 0x03000000
    (unaryfunc)alaqilPyObject_oct,  /*nb_oct*/
    (unaryfunc)alaqilPyObject_hex,  /*nb_hex*/
#endif
#if PY_VERSION_HEX >= 0x03050000 /* 3.5 */
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 /* nb_inplace_add -> nb_inplace_matrix_multiply */
#elif PY_VERSION_HEX >= 0x03000000 /* 3.0 */
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 /* nb_inplace_add -> nb_index, nb_inplace_divide removed */
#else
    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 /* nb_inplace_add -> nb_index */
#endif
  };

  static PyTypeObject alaqilpyobject_type;
  static int type_init = 0;
  if (!type_init) {
    const PyTypeObject tmp = {
#if PY_VERSION_HEX >= 0x03000000
      PyVarObject_HEAD_INIT(NULL, 0)
#else
      PyObject_HEAD_INIT(NULL)
      0,                                    /* ob_size */
#endif
      "alaqilPyObject",                       /* tp_name */
      sizeof(alaqilPyObject),                 /* tp_basicsize */
      0,                                    /* tp_itemsize */
      (destructor)alaqilPyObject_dealloc,     /* tp_dealloc */
      0,                                    /* tp_print */
      (getattrfunc)0,                       /* tp_getattr */
      (setattrfunc)0,                       /* tp_setattr */
#if PY_VERSION_HEX >= 0x03000000
      0, /* tp_reserved in 3.0.1, tp_compare in 3.0.0 but not used */
#else
      (cmpfunc)alaqilPyObject_compare,        /* tp_compare */
#endif
      (reprfunc)alaqilPyObject_repr,          /* tp_repr */
      &alaqilPyObject_as_number,              /* tp_as_number */
      0,                                    /* tp_as_sequence */
      0,                                    /* tp_as_mapping */
      (hashfunc)0,                          /* tp_hash */
      (ternaryfunc)0,                       /* tp_call */
      0,                                    /* tp_str */
      PyObject_GenericGetAttr,              /* tp_getattro */
      0,                                    /* tp_setattro */
      0,                                    /* tp_as_buffer */
      Py_TPFLAGS_DEFAULT,                   /* tp_flags */
      alaqilobject_doc,                       /* tp_doc */
      0,                                    /* tp_traverse */
      0,                                    /* tp_clear */
      (richcmpfunc)alaqilPyObject_richcompare,/* tp_richcompare */
      0,                                    /* tp_weaklistoffset */
      0,                                    /* tp_iter */
      0,                                    /* tp_iternext */
      alaqilobject_methods,                   /* tp_methods */
      0,                                    /* tp_members */
      0,                                    /* tp_getset */
      0,                                    /* tp_base */
      0,                                    /* tp_dict */
      0,                                    /* tp_descr_get */
      0,                                    /* tp_descr_set */
      0,                                    /* tp_dictoffset */
      0,                                    /* tp_init */
      0,                                    /* tp_alloc */
      0,                                    /* tp_new */
      0,                                    /* tp_free */
      0,                                    /* tp_is_gc */
      0,                                    /* tp_bases */
      0,                                    /* tp_mro */
      0,                                    /* tp_cache */
      0,                                    /* tp_subclasses */
      0,                                    /* tp_weaklist */
      0,                                    /* tp_del */
      0,                                    /* tp_version_tag */
#if PY_VERSION_HEX >= 0x03040000
      0,                                    /* tp_finalize */
#endif
#ifdef COUNT_ALLOCS
      0,                                    /* tp_allocs */
      0,                                    /* tp_frees */
      0,                                    /* tp_maxalloc */
      0,                                    /* tp_prev */
      0                                     /* tp_next */
#endif
    };
    alaqilpyobject_type = tmp;
    type_init = 1;
    if (PyType_Ready(&alaqilpyobject_type) < 0)
      return NULL;
  }
  return &alaqilpyobject_type;
}

alaqilRUNTIME PyObject *
alaqilPyObject_New(void *ptr, alaqil_type_info *ty, int own)
{
  alaqilPyObject *sobj = PyObject_NEW(alaqilPyObject, alaqilPyObject_type());
  if (sobj) {
    sobj->ptr  = ptr;
    sobj->ty   = ty;
    sobj->own  = own;
    sobj->next = 0;
  }
  return (PyObject *)sobj;
}

/* -----------------------------------------------------------------------------
 * Implements a simple alaqil Packed type, and use it instead of string
 * ----------------------------------------------------------------------------- */

typedef struct {
  PyObject_HEAD
  void *pack;
  alaqil_type_info *ty;
  size_t size;
} alaqilPyPacked;

alaqilRUNTIME PyObject *
alaqilPyPacked_repr(alaqilPyPacked *v)
{
  char result[alaqil_BUFFER_SIZE];
  if (alaqil_PackDataName(result, v->pack, v->size, 0, sizeof(result))) {
    return alaqil_Python_str_FromFormat("<alaqil Packed at %s%s>", result, v->ty->name);
  } else {
    return alaqil_Python_str_FromFormat("<alaqil Packed %s>", v->ty->name);
  }  
}

alaqilRUNTIME PyObject *
alaqilPyPacked_str(alaqilPyPacked *v)
{
  char result[alaqil_BUFFER_SIZE];
  if (alaqil_PackDataName(result, v->pack, v->size, 0, sizeof(result))){
    return alaqil_Python_str_FromFormat("%s%s", result, v->ty->name);
  } else {
    return alaqil_Python_str_FromChar(v->ty->name);
  }  
}

alaqilRUNTIME int
alaqilPyPacked_compare(alaqilPyPacked *v, alaqilPyPacked *w)
{
  size_t i = v->size;
  size_t j = w->size;
  int s = (i < j) ? -1 : ((i > j) ? 1 : 0);
  return s ? s : strncmp((const char *)v->pack, (const char *)w->pack, 2*v->size);
}

alaqilRUNTIME PyTypeObject* alaqilPyPacked_TypeOnce(void);

alaqilRUNTIME PyTypeObject*
alaqilPyPacked_type(void) {
  static PyTypeObject *alaqil_STATIC_POINTER(type) = alaqilPyPacked_TypeOnce();
  return type;
}

alaqilRUNTIMEINLINE int
alaqilPyPacked_Check(PyObject *op) {
  return ((op)->ob_type == alaqilPyPacked_TypeOnce()) 
    || (strcmp((op)->ob_type->tp_name,"alaqilPyPacked") == 0);
}

alaqilRUNTIME void
alaqilPyPacked_dealloc(PyObject *v)
{
  if (alaqilPyPacked_Check(v)) {
    alaqilPyPacked *sobj = (alaqilPyPacked *) v;
    free(sobj->pack);
  }
  PyObject_DEL(v);
}

alaqilRUNTIME PyTypeObject*
alaqilPyPacked_TypeOnce(void) {
  static char alaqilpacked_doc[] = "alaqil object carries a C/C++ instance pointer";
  static PyTypeObject alaqilpypacked_type;
  static int type_init = 0;
  if (!type_init) {
    const PyTypeObject tmp = {
#if PY_VERSION_HEX>=0x03000000
      PyVarObject_HEAD_INIT(NULL, 0)
#else
      PyObject_HEAD_INIT(NULL)
      0,                                    /* ob_size */
#endif
      "alaqilPyPacked",                       /* tp_name */
      sizeof(alaqilPyPacked),                 /* tp_basicsize */
      0,                                    /* tp_itemsize */
      (destructor)alaqilPyPacked_dealloc,     /* tp_dealloc */
      0,                                    /* tp_print */
      (getattrfunc)0,                       /* tp_getattr */
      (setattrfunc)0,                       /* tp_setattr */
#if PY_VERSION_HEX>=0x03000000
      0, /* tp_reserved in 3.0.1 */
#else
      (cmpfunc)alaqilPyPacked_compare,        /* tp_compare */
#endif
      (reprfunc)alaqilPyPacked_repr,          /* tp_repr */
      0,                                    /* tp_as_number */
      0,                                    /* tp_as_sequence */
      0,                                    /* tp_as_mapping */
      (hashfunc)0,                          /* tp_hash */
      (ternaryfunc)0,                       /* tp_call */
      (reprfunc)alaqilPyPacked_str,           /* tp_str */
      PyObject_GenericGetAttr,              /* tp_getattro */
      0,                                    /* tp_setattro */
      0,                                    /* tp_as_buffer */
      Py_TPFLAGS_DEFAULT,                   /* tp_flags */
      alaqilpacked_doc,                       /* tp_doc */
      0,                                    /* tp_traverse */
      0,                                    /* tp_clear */
      0,                                    /* tp_richcompare */
      0,                                    /* tp_weaklistoffset */
      0,                                    /* tp_iter */
      0,                                    /* tp_iternext */
      0,                                    /* tp_methods */
      0,                                    /* tp_members */
      0,                                    /* tp_getset */
      0,                                    /* tp_base */
      0,                                    /* tp_dict */
      0,                                    /* tp_descr_get */
      0,                                    /* tp_descr_set */
      0,                                    /* tp_dictoffset */
      0,                                    /* tp_init */
      0,                                    /* tp_alloc */
      0,                                    /* tp_new */
      0,                                    /* tp_free */
      0,                                    /* tp_is_gc */
      0,                                    /* tp_bases */
      0,                                    /* tp_mro */
      0,                                    /* tp_cache */
      0,                                    /* tp_subclasses */
      0,                                    /* tp_weaklist */
      0,                                    /* tp_del */
      0,                                    /* tp_version_tag */
#if PY_VERSION_HEX >= 0x03040000
      0,                                    /* tp_finalize */
#endif
#ifdef COUNT_ALLOCS
      0,                                    /* tp_allocs */
      0,                                    /* tp_frees */
      0,                                    /* tp_maxalloc */
      0,                                    /* tp_prev */
      0                                     /* tp_next */
#endif
    };
    alaqilpypacked_type = tmp;
    type_init = 1;
    if (PyType_Ready(&alaqilpypacked_type) < 0)
      return NULL;
  }
  return &alaqilpypacked_type;
}

alaqilRUNTIME PyObject *
alaqilPyPacked_New(void *ptr, size_t size, alaqil_type_info *ty)
{
  alaqilPyPacked *sobj = PyObject_NEW(alaqilPyPacked, alaqilPyPacked_type());
  if (sobj) {
    void *pack = malloc(size);
    if (pack) {
      memcpy(pack, ptr, size);
      sobj->pack = pack;
      sobj->ty   = ty;
      sobj->size = size;
    } else {
      PyObject_DEL((PyObject *) sobj);
      sobj = 0;
    }
  }
  return (PyObject *) sobj;
}

alaqilRUNTIME alaqil_type_info *
alaqilPyPacked_UnpackData(PyObject *obj, void *ptr, size_t size)
{
  if (alaqilPyPacked_Check(obj)) {
    alaqilPyPacked *sobj = (alaqilPyPacked *)obj;
    if (sobj->size != size) return 0;
    memcpy(ptr, sobj->pack, size);
    return sobj->ty;
  } else {
    return 0;
  }
}

/* -----------------------------------------------------------------------------
 * pointers/data manipulation
 * ----------------------------------------------------------------------------- */

static PyObject *alaqil_This_global = NULL;

alaqilRUNTIME PyObject *
alaqil_This(void)
{
  if (alaqil_This_global == NULL)
    alaqil_This_global = alaqil_Python_str_FromChar("this");
  return alaqil_This_global;
}

/* #define alaqil_PYTHON_SLOW_GETSET_THIS */

/* TODO: I don't know how to implement the fast getset in Python 3 right now */
#if PY_VERSION_HEX>=0x03000000
#define alaqil_PYTHON_SLOW_GETSET_THIS 
#endif

alaqilRUNTIME alaqilPyObject *
alaqil_Python_GetalaqilThis(PyObject *pyobj) 
{
  PyObject *obj;

  if (alaqilPyObject_Check(pyobj))
    return (alaqilPyObject *) pyobj;

#ifdef alaqilPYTHON_BUILTIN
  (void)obj;
# ifdef PyWeakref_CheckProxy
  if (PyWeakref_CheckProxy(pyobj)) {
    pyobj = PyWeakref_GET_OBJECT(pyobj);
    if (pyobj && alaqilPyObject_Check(pyobj))
      return (alaqilPyObject*) pyobj;
  }
# endif
  return NULL;
#else

  obj = 0;

#if !defined(alaqil_PYTHON_SLOW_GETSET_THIS)
  if (PyInstance_Check(pyobj)) {
    obj = _PyInstance_Lookup(pyobj, alaqil_This());      
  } else {
    PyObject **dictptr = _PyObject_GetDictPtr(pyobj);
    if (dictptr != NULL) {
      PyObject *dict = *dictptr;
      obj = dict ? PyDict_GetItem(dict, alaqil_This()) : 0;
    } else {
#ifdef PyWeakref_CheckProxy
      if (PyWeakref_CheckProxy(pyobj)) {
	PyObject *wobj = PyWeakref_GET_OBJECT(pyobj);
	return wobj ? alaqil_Python_GetalaqilThis(wobj) : 0;
      }
#endif
      obj = PyObject_GetAttr(pyobj,alaqil_This());
      if (obj) {
	Py_DECREF(obj);
      } else {
	if (PyErr_Occurred()) PyErr_Clear();
	return 0;
      }
    }
  }
#else
  obj = PyObject_GetAttr(pyobj,alaqil_This());
  if (obj) {
    Py_DECREF(obj);
  } else {
    if (PyErr_Occurred()) PyErr_Clear();
    return 0;
  }
#endif
  if (obj && !alaqilPyObject_Check(obj)) {
    /* a PyObject is called 'this', try to get the 'real this'
       alaqilPyObject from it */ 
    return alaqil_Python_GetalaqilThis(obj);
  }
  return (alaqilPyObject *)obj;
#endif
}

/* Acquire a pointer value */

alaqilRUNTIME int
alaqil_Python_AcquirePtr(PyObject *obj, int own) {
  if (own == alaqil_POINTER_OWN) {
    alaqilPyObject *sobj = alaqil_Python_GetalaqilThis(obj);
    if (sobj) {
      int oldown = sobj->own;
      sobj->own = own;
      return oldown;
    }
  }
  return 0;
}

/* Convert a pointer value */

alaqilRUNTIME int
alaqil_Python_ConvertPtrAndOwn(PyObject *obj, void **ptr, alaqil_type_info *ty, int flags, int *own) {
  int res;
  alaqilPyObject *sobj;
  int implicit_conv = (flags & alaqil_POINTER_IMPLICIT_CONV) != 0;

  if (!obj)
    return alaqil_ERROR;
  if (obj == Py_None && !implicit_conv) {
    if (ptr)
      *ptr = 0;
    return (flags & alaqil_POINTER_NO_NULL) ? alaqil_NullReferenceError : alaqil_OK;
  }

  res = alaqil_ERROR;

  sobj = alaqil_Python_GetalaqilThis(obj);
  if (own)
    *own = 0;
  while (sobj) {
    void *vptr = sobj->ptr;
    if (ty) {
      alaqil_type_info *to = sobj->ty;
      if (to == ty) {
        /* no type cast needed */
        if (ptr) *ptr = vptr;
        break;
      } else {
        alaqil_cast_info *tc = alaqil_TypeCheck(to->name,ty);
        if (!tc) {
          sobj = (alaqilPyObject *)sobj->next;
        } else {
          if (ptr) {
            int newmemory = 0;
            *ptr = alaqil_TypeCast(tc,vptr,&newmemory);
            if (newmemory == alaqil_CAST_NEW_MEMORY) {
              assert(own); /* badly formed typemap which will lead to a memory leak - it must set and use own to delete *ptr */
              if (own)
                *own = *own | alaqil_CAST_NEW_MEMORY;
            }
          }
          break;
        }
      }
    } else {
      if (ptr) *ptr = vptr;
      break;
    }
  }
  if (sobj) {
    if (own)
      *own = *own | sobj->own;
    if (flags & alaqil_POINTER_DISOWN) {
      sobj->own = 0;
    }
    res = alaqil_OK;
  } else {
    if (implicit_conv) {
      alaqilPyClientData *data = ty ? (alaqilPyClientData *) ty->clientdata : 0;
      if (data && !data->implicitconv) {
        PyObject *klass = data->klass;
        if (klass) {
          PyObject *impconv;
          data->implicitconv = 1; /* avoid recursion and call 'explicit' constructors*/
          impconv = alaqil_Python_CallFunctor(klass, obj);
          data->implicitconv = 0;
          if (PyErr_Occurred()) {
            PyErr_Clear();
            impconv = 0;
          }
          if (impconv) {
            alaqilPyObject *iobj = alaqil_Python_GetalaqilThis(impconv);
            if (iobj) {
              void *vptr;
              res = alaqil_Python_ConvertPtrAndOwn((PyObject*)iobj, &vptr, ty, 0, 0);
              if (alaqil_IsOK(res)) {
                if (ptr) {
                  *ptr = vptr;
                  /* transfer the ownership to 'ptr' */
                  iobj->own = 0;
                  res = alaqil_AddCast(res);
                  res = alaqil_AddNewMask(res);
                } else {
                  res = alaqil_AddCast(res);		    
                }
              }
            }
            Py_DECREF(impconv);
          }
        }
      }
      if (!alaqil_IsOK(res) && obj == Py_None) {
        if (ptr)
          *ptr = 0;
        if (PyErr_Occurred())
          PyErr_Clear();
        res = alaqil_OK;
      }
    }
  }
  return res;
}

/* Convert a function ptr value */

alaqilRUNTIME int
alaqil_Python_ConvertFunctionPtr(PyObject *obj, void **ptr, alaqil_type_info *ty) {
  if (!PyCFunction_Check(obj)) {
    return alaqil_ConvertPtr(obj, ptr, ty, 0);
  } else {
    void *vptr = 0;
    alaqil_cast_info *tc;

    /* here we get the method pointer for callbacks */
    const char *doc = (((PyCFunctionObject *)obj) -> m_ml -> ml_doc);
    const char *desc = doc ? strstr(doc, "alaqil_ptr: ") : 0;
    if (desc)
      desc = ty ? alaqil_UnpackVoidPtr(desc + 10, &vptr, ty->name) : 0;
    if (!desc)
      return alaqil_ERROR;
    tc = alaqil_TypeCheck(desc,ty);
    if (tc) {
      int newmemory = 0;
      *ptr = alaqil_TypeCast(tc,vptr,&newmemory);
      assert(!newmemory); /* newmemory handling not yet implemented */
    } else {
      return alaqil_ERROR;
    }
    return alaqil_OK;
  }
}

/* Convert a packed pointer value */

alaqilRUNTIME int
alaqil_Python_ConvertPacked(PyObject *obj, void *ptr, size_t sz, alaqil_type_info *ty) {
  alaqil_type_info *to = alaqilPyPacked_UnpackData(obj, ptr, sz);
  if (!to) return alaqil_ERROR;
  if (ty) {
    if (to != ty) {
      /* check type cast? */
      alaqil_cast_info *tc = alaqil_TypeCheck(to->name,ty);
      if (!tc) return alaqil_ERROR;
    }
  }
  return alaqil_OK;
}  

/* -----------------------------------------------------------------------------
 * Create a new pointer object
 * ----------------------------------------------------------------------------- */

/*
  Create a new instance object, without calling __init__, and set the
  'this' attribute.
*/

alaqilRUNTIME PyObject* 
alaqil_Python_NewShadowInstance(alaqilPyClientData *data, PyObject *alaqil_this)
{
  PyObject *inst = 0;
  PyObject *newraw = data->newraw;
  if (newraw) {
    inst = PyObject_Call(newraw, data->newargs, NULL);
    if (inst) {
#if !defined(alaqil_PYTHON_SLOW_GETSET_THIS)
      PyObject **dictptr = _PyObject_GetDictPtr(inst);
      if (dictptr != NULL) {
	PyObject *dict = *dictptr;
	if (dict == NULL) {
	  dict = PyDict_New();
	  *dictptr = dict;
	  PyDict_SetItem(dict, alaqil_This(), alaqil_this);
	}
      }
#else
      PyObject *key = alaqil_This();
      PyObject_SetAttr(inst, key, alaqil_this);
#endif
    }
  } else {
#if PY_VERSION_HEX >= 0x03000000
    PyObject *empty_args = PyTuple_New(0);
    if (empty_args) {
      PyObject *empty_kwargs = PyDict_New();
      if (empty_kwargs) {
        inst = ((PyTypeObject *)data->newargs)->tp_new((PyTypeObject *)data->newargs, empty_args, empty_kwargs);
        Py_DECREF(empty_kwargs);
        if (inst) {
          PyObject_SetAttr(inst, alaqil_This(), alaqil_this);
          Py_TYPE(inst)->tp_flags &= ~Py_TPFLAGS_VALID_VERSION_TAG;
        }
      }
      Py_DECREF(empty_args);
    }
#else
    PyObject *dict = PyDict_New();
    if (dict) {
      PyDict_SetItem(dict, alaqil_This(), alaqil_this);
      inst = PyInstance_NewRaw(data->newargs, dict);
      Py_DECREF(dict);
    }
#endif
  }
  return inst;
}

alaqilRUNTIME void
alaqil_Python_SetalaqilThis(PyObject *inst, PyObject *alaqil_this)
{
 PyObject *dict;
#if !defined(alaqil_PYTHON_SLOW_GETSET_THIS)
 PyObject **dictptr = _PyObject_GetDictPtr(inst);
 if (dictptr != NULL) {
   dict = *dictptr;
   if (dict == NULL) {
     dict = PyDict_New();
     *dictptr = dict;
   }
   PyDict_SetItem(dict, alaqil_This(), alaqil_this);
   return;
 }
#endif
 dict = PyObject_GetAttrString(inst, "__dict__");
 PyDict_SetItem(dict, alaqil_This(), alaqil_this);
 Py_DECREF(dict);
} 


alaqilINTERN PyObject *
alaqil_Python_InitShadowInstance(PyObject *args) {
  PyObject *obj[2];
  if (!alaqil_Python_UnpackTuple(args, "alaqilinit", 2, 2, obj)) {
    return NULL;
  } else {
    alaqilPyObject *sthis = alaqil_Python_GetalaqilThis(obj[0]);
    if (sthis) {
      alaqilPyObject_append((PyObject*) sthis, obj[1]);
    } else {
      alaqil_Python_SetalaqilThis(obj[0], obj[1]);
    }
    return alaqil_Py_Void();
  }
}

/* Create a new pointer object */

alaqilRUNTIME PyObject *
alaqil_Python_NewPointerObj(PyObject *self, void *ptr, alaqil_type_info *type, int flags) {
  alaqilPyClientData *clientdata;
  PyObject * robj;
  int own;

  if (!ptr)
    return alaqil_Py_Void();

  clientdata = type ? (alaqilPyClientData *)(type->clientdata) : 0;
  own = (flags & alaqil_POINTER_OWN) ? alaqil_POINTER_OWN : 0;
  if (clientdata && clientdata->pytype) {
    alaqilPyObject *newobj;
    if (flags & alaqil_BUILTIN_TP_INIT) {
      newobj = (alaqilPyObject*) self;
      if (newobj->ptr) {
        PyObject *next_self = clientdata->pytype->tp_alloc(clientdata->pytype, 0);
        while (newobj->next)
	  newobj = (alaqilPyObject *) newobj->next;
        newobj->next = next_self;
        newobj = (alaqilPyObject *)next_self;
#ifdef alaqilPYTHON_BUILTIN
        newobj->dict = 0;
#endif
      }
    } else {
      newobj = PyObject_New(alaqilPyObject, clientdata->pytype);
#ifdef alaqilPYTHON_BUILTIN
      newobj->dict = 0;
#endif
    }
    if (newobj) {
      newobj->ptr = ptr;
      newobj->ty = type;
      newobj->own = own;
      newobj->next = 0;
      return (PyObject*) newobj;
    }
    return alaqil_Py_Void();
  }

  assert(!(flags & alaqil_BUILTIN_TP_INIT));

  robj = alaqilPyObject_New(ptr, type, own);
  if (robj && clientdata && !(flags & alaqil_POINTER_NOSHADOW)) {
    PyObject *inst = alaqil_Python_NewShadowInstance(clientdata, robj);
    Py_DECREF(robj);
    robj = inst;
  }
  return robj;
}

/* Create a new packed object */

alaqilRUNTIMEINLINE PyObject *
alaqil_Python_NewPackedObj(void *ptr, size_t sz, alaqil_type_info *type) {
  return ptr ? alaqilPyPacked_New((void *) ptr, sz, type) : alaqil_Py_Void();
}

/* -----------------------------------------------------------------------------*
 *  Get type list 
 * -----------------------------------------------------------------------------*/

#ifdef alaqil_LINK_RUNTIME
void *alaqil_ReturnGlobalTypeList(void *);
#endif

alaqilRUNTIME alaqil_module_info *
alaqil_Python_GetModule(void *alaqilUNUSEDPARM(clientdata)) {
  static void *type_pointer = (void *)0;
  /* first check if module already created */
  if (!type_pointer) {
#ifdef alaqil_LINK_RUNTIME
    type_pointer = alaqil_ReturnGlobalTypeList((void *)0);
#else
    type_pointer = PyCapsule_Import(alaqilPY_CAPSULE_NAME, 0);
    if (PyErr_Occurred()) {
      PyErr_Clear();
      type_pointer = (void *)0;
    }
#endif
  }
  return (alaqil_module_info *) type_pointer;
}

alaqilRUNTIME void
alaqil_Python_DestroyModule(PyObject *obj)
{
  alaqil_module_info *alaqil_module = (alaqil_module_info *) PyCapsule_GetPointer(obj, alaqilPY_CAPSULE_NAME);
  alaqil_type_info **types = alaqil_module->types;
  size_t i;
  for (i =0; i < alaqil_module->size; ++i) {
    alaqil_type_info *ty = types[i];
    if (ty->owndata) {
      alaqilPyClientData *data = (alaqilPyClientData *) ty->clientdata;
      if (data) alaqilPyClientData_Del(data);
    }
  }
  Py_DECREF(alaqil_This());
  alaqil_This_global = NULL;
}

alaqilRUNTIME void
alaqil_Python_SetModule(alaqil_module_info *alaqil_module) {
#if PY_VERSION_HEX >= 0x03000000
 /* Add a dummy module object into sys.modules */
  PyObject *module = PyImport_AddModule("alaqil_runtime_data" alaqil_RUNTIME_VERSION);
#else
  static PyMethodDef alaqil_empty_runtime_method_table[] = { {NULL, NULL, 0, NULL} }; /* Sentinel */
  PyObject *module = Py_InitModule("alaqil_runtime_data" alaqil_RUNTIME_VERSION, alaqil_empty_runtime_method_table);
#endif
  PyObject *pointer = PyCapsule_New((void *) alaqil_module, alaqilPY_CAPSULE_NAME, alaqil_Python_DestroyModule);
  if (pointer && module) {
    PyModule_AddObject(module, "type_pointer_capsule" alaqil_TYPE_TABLE_NAME, pointer);
  } else {
    Py_XDECREF(pointer);
  }
}

/* The python cached type query */
alaqilRUNTIME PyObject *
alaqil_Python_TypeCache(void) {
  static PyObject *alaqil_STATIC_POINTER(cache) = PyDict_New();
  return cache;
}

alaqilRUNTIME alaqil_type_info *
alaqil_Python_TypeQuery(const char *type)
{
  PyObject *cache = alaqil_Python_TypeCache();
  PyObject *key = alaqil_Python_str_FromChar(type); 
  PyObject *obj = PyDict_GetItem(cache, key);
  alaqil_type_info *descriptor;
  if (obj) {
    descriptor = (alaqil_type_info *) PyCapsule_GetPointer(obj, NULL);
  } else {
    alaqil_module_info *alaqil_module = alaqil_GetModule(0);
    descriptor = alaqil_TypeQueryModule(alaqil_module, alaqil_module, type);
    if (descriptor) {
      obj = PyCapsule_New((void*) descriptor, NULL, NULL);
      PyDict_SetItem(cache, key, obj);
      Py_DECREF(obj);
    }
  }
  Py_DECREF(key);
  return descriptor;
}

/* 
   For backward compatibility only
*/
#define alaqil_POINTER_EXCEPTION  0
#define alaqil_arg_fail(arg)      alaqil_Python_ArgFail(arg)
#define alaqil_MustGetPtr(p, type, argnum, flags)  alaqil_Python_MustGetPtr(p, type, argnum, flags)

alaqilRUNTIME int
alaqil_Python_AddErrMesg(const char* mesg, int infront)
{  
  if (PyErr_Occurred()) {
    PyObject *type = 0;
    PyObject *value = 0;
    PyObject *traceback = 0;
    PyErr_Fetch(&type, &value, &traceback);
    if (value) {
      PyObject *old_str = PyObject_Str(value);
      const char *tmp = alaqil_Python_str_AsChar(old_str);
      const char *errmesg = tmp ? tmp : "Invalid error message";
      Py_XINCREF(type);
      PyErr_Clear();
      if (infront) {
	PyErr_Format(type, "%s %s", mesg, errmesg);
      } else {
	PyErr_Format(type, "%s %s", errmesg, mesg);
      }
      alaqil_Python_str_DelForPy3(tmp);
      Py_DECREF(old_str);
    }
    return 1;
  } else {
    return 0;
  }
}
  
alaqilRUNTIME int
alaqil_Python_ArgFail(int argnum)
{
  if (PyErr_Occurred()) {
    /* add information about failing argument */
    char mesg[256];
    PyOS_snprintf(mesg, sizeof(mesg), "argument number %d:", argnum);
    return alaqil_Python_AddErrMesg(mesg, 1);
  } else {
    return 0;
  }
}

alaqilRUNTIMEINLINE const char *
alaqilPyObject_GetDesc(PyObject *self)
{
  alaqilPyObject *v = (alaqilPyObject *)self;
  alaqil_type_info *ty = v ? v->ty : 0;
  return ty ? ty->str : "";
}

alaqilRUNTIME void
alaqil_Python_TypeError(const char *type, PyObject *obj)
{
  if (type) {
#if defined(alaqil_COBJECT_TYPES)
    if (obj && alaqilPyObject_Check(obj)) {
      const char *otype = (const char *) alaqilPyObject_GetDesc(obj);
      if (otype) {
	PyErr_Format(PyExc_TypeError, "a '%s' is expected, 'alaqilPyObject(%s)' is received",
		     type, otype);
	return;
      }
    } else 
#endif      
    {
      const char *otype = (obj ? obj->ob_type->tp_name : 0); 
      if (otype) {
	PyObject *str = PyObject_Str(obj);
	const char *cstr = str ? alaqil_Python_str_AsChar(str) : 0;
	if (cstr) {
	  PyErr_Format(PyExc_TypeError, "a '%s' is expected, '%s(%s)' is received",
		       type, otype, cstr);
          alaqil_Python_str_DelForPy3(cstr);
	} else {
	  PyErr_Format(PyExc_TypeError, "a '%s' is expected, '%s' is received",
		       type, otype);
	}
	Py_XDECREF(str);
	return;
      }
    }   
    PyErr_Format(PyExc_TypeError, "a '%s' is expected", type);
  } else {
    PyErr_Format(PyExc_TypeError, "unexpected type is received");
  }
}


/* Convert a pointer value, signal an exception on a type mismatch */
alaqilRUNTIME void *
alaqil_Python_MustGetPtr(PyObject *obj, alaqil_type_info *ty, int alaqilUNUSEDPARM(argnum), int flags) {
  void *result;
  if (alaqil_Python_ConvertPtr(obj, &result, ty, flags) == -1) {
    PyErr_Clear();
#if alaqil_POINTER_EXCEPTION
    if (flags) {
      alaqil_Python_TypeError(alaqil_TypePrettyName(ty), obj);
      alaqil_Python_ArgFail(argnum);
    }
#endif
  }
  return result;
}

#ifdef alaqilPYTHON_BUILTIN
alaqilRUNTIME int
alaqil_Python_NonDynamicSetAttr(PyObject *obj, PyObject *name, PyObject *value) {
  PyTypeObject *tp = obj->ob_type;
  PyObject *descr;
  PyObject *encoded_name;
  descrsetfunc f;
  int res = -1;

# ifdef Py_USING_UNICODE
  if (PyString_Check(name)) {
    name = PyUnicode_Decode(PyString_AsString(name), PyString_Size(name), NULL, NULL);
    if (!name)
      return -1;
  } else if (!PyUnicode_Check(name))
# else
  if (!PyString_Check(name))
# endif
  {
    PyErr_Format(PyExc_TypeError, "attribute name must be string, not '%.200s'", name->ob_type->tp_name);
    return -1;
  } else {
    Py_INCREF(name);
  }

  if (!tp->tp_dict) {
    if (PyType_Ready(tp) < 0)
      goto done;
  }

  descr = _PyType_Lookup(tp, name);
  f = NULL;
  if (descr != NULL)
    f = descr->ob_type->tp_descr_set;
  if (!f) {
    if (PyString_Check(name)) {
      encoded_name = name;
      Py_INCREF(name);
    } else {
      encoded_name = PyUnicode_AsUTF8String(name);
      if (!encoded_name)
        return -1;
    }
    PyErr_Format(PyExc_AttributeError, "'%.100s' object has no attribute '%.200s'", tp->tp_name, PyString_AsString(encoded_name));
    Py_DECREF(encoded_name);
  } else {
    res = f(descr, obj, value);
  }
  
  done:
  Py_DECREF(name);
  return res;
}
#endif


#ifdef __cplusplus
}
#endif
