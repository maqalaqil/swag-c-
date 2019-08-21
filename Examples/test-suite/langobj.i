%module langobj


#ifndef alaqil_Object
#define alaqil_Object void *
#endif


%inline %{

#ifdef alaqilTCL
#define alaqil_Object Tcl_Obj *
#endif

#ifdef alaqilPYTHON
#define alaqil_Object PyObject *
#endif

#ifdef alaqilRUBY
#define alaqil_Object VALUE
#endif

#ifndef alaqil_Object
#define alaqil_Object void *
#endif

%}


%inline {

  alaqil_Object identity(alaqil_Object x) {
#ifdef alaqilPYTHON
    Py_XINCREF(x);
#endif
    return x;    
  }

}

  
