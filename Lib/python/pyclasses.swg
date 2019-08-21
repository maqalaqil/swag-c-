#ifdef __cplusplus

/*
  alaqilPtr_PyObject is used as a replacement of PyObject *, where
  the INCREF/DECREF are applied as needed.

  You can use alaqilPtr_PyObject in a container, such as
  
     std::vector<alaqilPtr_PyObject>;

  or as a member variable:
  
     struct A {
       alaqilPtr_PyObject obj;
       A(PyObject *o) : _obj(o) {
       }
     };

   or as a input/output value 

     alaqilPtr_PyObject func(alaqilPtr_PyObject obj) {     
       alaqilPtr_PyObject out = PyString_FromFormat("hello %s", PyObject_AsString(obj));
       Py_DECREF(out);
       return out;
     }

   just remember to pair the object creation with the proper DECREF,
   the same as with plain PyObject *ptr, since alaqilPtr_PyObject always add
   one reference at construction.

   alaqilPtr_PyObject is 'visible' at the wrapped side, so you can do:


      %template(pyvector) std::vector<alaqil::alaqilPtr_PyObject>;

   and all the proper typemaps will be used.
   
*/

namespace alaqil {
  %ignore alaqilPtr_PyObject;
  struct alaqilPtr_PyObject {};
  %apply PyObject * {alaqilPtr_PyObject};
  %apply PyObject * const& {alaqilPtr_PyObject const&};

  %typemap(typecheck,precedence=alaqil_TYPECHECK_alaqilOBJECT,noblock=1) alaqilPtr_PyObject const& "$1 = ($input != 0);";


  /* For output */
  %typemap(out,noblock=1)  alaqilPtr_PyObject {
    $result = (PyObject *)$1;
    Py_INCREF($result);
  }
  
  %typemap(out,noblock=1)  alaqilPtr_PyObject const & {
    $result = (PyObject *)*$1;
    Py_INCREF($result);
  }
  
}

%{
namespace alaqil {
  class alaqilPtr_PyObject {
  protected:
    PyObject *_obj;

  public:
    alaqilPtr_PyObject() :_obj(0)
    {
    }

    alaqilPtr_PyObject(const alaqilPtr_PyObject& item) : _obj(item._obj)
    {
      alaqil_PYTHON_THREAD_BEGIN_BLOCK;
      Py_XINCREF(_obj);      
      alaqil_PYTHON_THREAD_END_BLOCK;
    }
    
    alaqilPtr_PyObject(PyObject *obj, bool initial_ref = true) :_obj(obj)
    {
      if (initial_ref) {
        alaqil_PYTHON_THREAD_BEGIN_BLOCK;
        Py_XINCREF(_obj);
        alaqil_PYTHON_THREAD_END_BLOCK;
      }
    }
    
    alaqilPtr_PyObject & operator=(const alaqilPtr_PyObject& item) 
    {
      alaqil_PYTHON_THREAD_BEGIN_BLOCK;
      Py_XINCREF(item._obj);
      Py_XDECREF(_obj);
      _obj = item._obj;
      alaqil_PYTHON_THREAD_END_BLOCK;
      return *this;      
    }
    
    ~alaqilPtr_PyObject() 
    {
      alaqil_PYTHON_THREAD_BEGIN_BLOCK;
      Py_XDECREF(_obj);
      alaqil_PYTHON_THREAD_END_BLOCK;
    }
    
    operator PyObject *() const
    {
      return _obj;
    }

    PyObject *operator->() const
    {
      return _obj;
    }
  };
}
%}

/*
  alaqilVar_PyObject is used to manage 'in the scope' PyObject * variables,
  as in

  int func () {
    alaqilVar_PyObject obj = PyString_FromString("hello");
  }

  ie, 'obj' is created and destructed in the same scope from
  a python object that carries at least one reference value.
  
  alaqilVar_PyObject just take care of applying the proper Py_DECREF.

  Hence, this class is purely internal and not visible at the wrapped side.
 */
namespace alaqil {
  %ignore alaqilVar_PyObject;
  struct alaqilVar_PyObject {};
  %apply PyObject * {alaqilVar_PyObject};
  %apply PyObject * const& {alaqilVar_PyObject const&};
}

%{
namespace alaqil {
  struct alaqilVar_PyObject : alaqilPtr_PyObject {
    alaqilVar_PyObject(PyObject* obj = 0) : alaqilPtr_PyObject(obj, false) { }
    
    alaqilVar_PyObject & operator = (PyObject* obj)
    {
      Py_XDECREF(_obj);
      _obj = obj;
      return *this;      
    }
  };
}
%}


#endif
