/* ------------------------------------------------------------
 *  Typemap specializations for Python
 * ------------------------------------------------------------ */

/* ------------------------------------------------------------
 *  Fragment section
 * ------------------------------------------------------------ */
#ifdef alaqil_PYTHON_LEGACY_BOOL
// Default prior to alaqil 3.0.0
#undef alaqil_TYPECHECK_BOOL
%define alaqil_TYPECHECK_BOOL             10000 %enddef
#endif

/* Include fundamental fragment definitions */
%include <typemaps/fragments.swg>

/* Look for user fragments file. */
%include <pyfragments.swg>

/* Python fragments for fundamental types */
%include <pyprimtypes.swg>

/* Python fragments for char* strings */
%include <pystrings.swg>

/* Backward compatibility output helper */
%fragment("t_output_helper","header") %{
#define t_output_helper alaqil_Python_AppendOutput
%}


/* ------------------------------------------------------------
 *  Unified typemap section
 * ------------------------------------------------------------ */

/* directors are supported in Python */
#ifndef alaqil_DIRECTOR_TYPEMAPS
#define alaqil_DIRECTOR_TYPEMAPS
#endif


/* Python types */
#define alaqil_Object                     PyObject *
#define VOID_Object                     alaqil_Py_Void()

/* Python allows implicit conversion */
#define %implicitconv_flag              $implicitconv 


/* Overload of the output/constant/exception/dirout handling */

/* append output */
#define alaqil_AppendOutput(result, obj)  alaqil_Python_AppendOutput(result, obj)

/* set constant */
#if defined(alaqilPYTHON_BUILTIN)
#define alaqil_SetConstant(name, obj) alaqil_Python_SetConstant(d, d == md ? public_interface : NULL, name,obj) 
#else
#define alaqil_SetConstant(name, obj) alaqil_Python_SetConstant(d, name,obj) 
#endif

/* raise */
#define alaqil_Raise(obj, type, desc)     alaqil_Python_Raise(obj, type, desc)

/* Include the unified typemap library */
%include <typemaps/alaqiltypemaps.swg>


/*  ------------------------------------------------------------
 *  Python extra typemaps / typemap overrides
 * ------------------------------------------------------------ */

/* Get the address of the 'python self' object */

%typemap(in,numinputs=0,noblock=1) PyObject **PYTHON_SELF {
  $1 = &$self;
}


/* Consttab, needed for callbacks, it should be removed later */

%typemap(consttab) alaqilTYPE ((*)(ANY))
{ alaqil_PY_POINTER, "$symname", 0, 0, (void *)($value), &$descriptor }
%typemap(consttab) alaqilTYPE ((* const)(ANY)) = alaqilTYPE ((*)(ANY));

%typemap(constcode) alaqilTYPE ((*)(ANY)) "";
%typemap(constcode) alaqilTYPE ((* const)(ANY)) = alaqilTYPE ((*)(ANY));


/* Smart Pointers */
%typemap(out,noblock=1) const alaqilTYPE & SMARTPOINTER  {
  $result = alaqil_NewPointerObj(%new_copy(*$1, $*ltype), $descriptor, alaqil_POINTER_OWN | %newpointer_flags);
}

%typemap(ret,noblock=1) const alaqilTYPE & SMARTPOINTER, alaqilTYPE SMARTPOINTER {
  if ($result) {
    PyObject *robj = PyObject_CallMethod($result, (char *)"__deref__", NULL);
    if (robj && !PyErr_Occurred()) {
      alaqilPyObject_append((PyObject *) alaqil_Python_GetalaqilThis($result), 
			  (PyObject *) alaqil_Python_GetalaqilThis(robj));
      Py_DECREF(robj);
    }
  }
}

