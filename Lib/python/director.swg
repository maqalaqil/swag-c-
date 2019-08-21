/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that Python proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

#ifndef alaqil_DIRECTOR_PYTHON_HEADER_
#define alaqil_DIRECTOR_PYTHON_HEADER_

#include <string>
#include <iostream>
#include <exception>
#include <vector>
#include <map>


/*
  Use -Dalaqil_PYTHON_DIRECTOR_NO_VTABLE if you don't want to generate a 'virtual
  table', and avoid multiple GetAttr calls to retrieve the python
  methods.
*/

#ifndef alaqil_PYTHON_DIRECTOR_NO_VTABLE
#ifndef alaqil_PYTHON_DIRECTOR_VTABLE
#define alaqil_PYTHON_DIRECTOR_VTABLE
#endif
#endif



/*
  Use -Dalaqil_DIRECTOR_NO_UEH if you prefer to avoid the use of the
  Undefined Exception Handler provided by alaqil.
*/
#ifndef alaqil_DIRECTOR_NO_UEH
#ifndef alaqil_DIRECTOR_UEH
#define alaqil_DIRECTOR_UEH
#endif
#endif


/*
  Use -Dalaqil_DIRECTOR_NORTTI if you prefer to avoid the use of the
  native C++ RTTI and dynamic_cast<>. But be aware that directors
  could stop working when using this option.
*/
#ifdef alaqil_DIRECTOR_NORTTI
/*
   When we don't use the native C++ RTTI, we implement a minimal one
   only for Directors.
*/
# ifndef alaqil_DIRECTOR_RTDIR
# define alaqil_DIRECTOR_RTDIR

namespace alaqil {
  class Director;
  alaqilINTERN std::map<void *, Director *>& get_rtdir_map() {
    static std::map<void *, Director *> rtdir_map;
    return rtdir_map;
  }

  alaqilINTERNINLINE void set_rtdir(void *vptr, Director *rtdir) {
    get_rtdir_map()[vptr] = rtdir;
  }

  alaqilINTERNINLINE Director *get_rtdir(void *vptr) {
    std::map<void *, Director *>::const_iterator pos = get_rtdir_map().find(vptr);
    Director *rtdir = (pos != get_rtdir_map().end()) ? pos->second : 0;
    return rtdir;
  }
}
# endif /* alaqil_DIRECTOR_RTDIR */

# define alaqil_DIRECTOR_CAST(ARG) alaqil::get_rtdir(static_cast<void *>(ARG))
# define alaqil_DIRECTOR_RGTR(ARG1, ARG2) alaqil::set_rtdir(static_cast<void *>(ARG1), ARG2)

#else

# define alaqil_DIRECTOR_CAST(ARG) dynamic_cast<alaqil::Director *>(ARG)
# define alaqil_DIRECTOR_RGTR(ARG1, ARG2)

#endif /* alaqil_DIRECTOR_NORTTI */

extern "C" {
  struct alaqil_type_info;
}

namespace alaqil {

  /* memory handler */
  struct GCItem {
    virtual ~GCItem() {}

    virtual int get_own() const {
      return 0;
    }
  };

  struct GCItem_var {
    GCItem_var(GCItem *item = 0) : _item(item) {
    }

    GCItem_var& operator=(GCItem *item) {
      GCItem *tmp = _item;
      _item = item;
      delete tmp;
      return *this;
    }

    ~GCItem_var() {
      delete _item;
    }

    GCItem * operator->() const {
      return _item;
    }

  private:
    GCItem *_item;
  };

  struct GCItem_Object : GCItem {
    GCItem_Object(int own) : _own(own) {
    }

    virtual ~GCItem_Object() {
    }

    int get_own() const {
      return _own;
    }

  private:
    int _own;
  };

  template <typename Type>
  struct GCItem_T : GCItem {
    GCItem_T(Type *ptr) : _ptr(ptr) {
    }

    virtual ~GCItem_T() {
      delete _ptr;
    }

  private:
    Type *_ptr;
  };

  template <typename Type>
  struct GCArray_T : GCItem {
    GCArray_T(Type *ptr) : _ptr(ptr) {
    }

    virtual ~GCArray_T() {
      delete[] _ptr;
    }

  private:
    Type *_ptr;
  };

  /* base class for director exceptions */
  class DirectorException : public std::exception {
  protected:
    std::string alaqil_msg;
  public:
    DirectorException(PyObject *error, const char *hdr ="", const char *msg ="") : alaqil_msg(hdr) {
      alaqil_PYTHON_THREAD_BEGIN_BLOCK;
      if (msg[0]) {
        alaqil_msg += " ";
        alaqil_msg += msg;
      }
      if (!PyErr_Occurred()) {
        PyErr_SetString(error, what());
      }
      alaqil_PYTHON_THREAD_END_BLOCK;
    }

    virtual ~DirectorException() throw() {
    }

    /* Deprecated, use what() instead */
    const char *getMessage() const {
      return what();
    }

    const char *what() const throw() {
      return alaqil_msg.c_str();
    }

    static void raise(PyObject *error, const char *msg) {
      throw DirectorException(error, msg);
    }

    static void raise(const char *msg) {
      raise(PyExc_RuntimeError, msg);
    }
  };

  /* unknown exception handler  */
  class UnknownExceptionHandler {
#ifdef alaqil_DIRECTOR_UEH
    static void handler() {
      try {
        throw;
      } catch (DirectorException& e) {
        std::cerr << "alaqil Director exception caught:" << std::endl
                  << e.what() << std::endl;
      } catch (std::exception& e) {
        std::cerr << "std::exception caught: "<< e.what() << std::endl;
      } catch (...) {
        std::cerr << "Unknown exception caught." << std::endl;
      }

      std::cerr << std::endl
                << "Python interpreter traceback:" << std::endl;
      PyErr_Print();
      std::cerr << std::endl;

      std::cerr << "This exception was caught by the alaqil unexpected exception handler." << std::endl
                << "Try using %feature(\"director:except\") to avoid reaching this point." << std::endl
                << std::endl
                << "Exception is being re-thrown, program will likely abort/terminate." << std::endl;
      throw;
    }

  public:

    std::unexpected_handler old;
    UnknownExceptionHandler(std::unexpected_handler nh = handler) {
      old = std::set_unexpected(nh);
    }

    ~UnknownExceptionHandler() {
      std::set_unexpected(old);
    }
#endif
  };

  /* type mismatch in the return value from a python method call */
  class DirectorTypeMismatchException : public DirectorException {
  public:
    DirectorTypeMismatchException(PyObject *error, const char *msg="")
      : DirectorException(error, "alaqil director type mismatch", msg) {
    }

    DirectorTypeMismatchException(const char *msg="")
      : DirectorException(PyExc_TypeError, "alaqil director type mismatch", msg) {
    }

    static void raise(PyObject *error, const char *msg) {
      throw DirectorTypeMismatchException(error, msg);
    }

    static void raise(const char *msg) {
      throw DirectorTypeMismatchException(msg);
    }
  };

  /* any python exception that occurs during a director method call */
  class DirectorMethodException : public DirectorException {
  public:
    DirectorMethodException(const char *msg = "")
      : DirectorException(PyExc_RuntimeError, "alaqil director method error.", msg) {
    }

    static void raise(const char *msg) {
      throw DirectorMethodException(msg);
    }
  };

  /* attempt to call a pure virtual method via a director method */
  class DirectorPureVirtualException : public DirectorException {
  public:
    DirectorPureVirtualException(const char *msg = "")
      : DirectorException(PyExc_RuntimeError, "alaqil director pure virtual method called", msg) {
    }

    static void raise(const char *msg) {
      throw DirectorPureVirtualException(msg);
    }
  };


#if defined(alaqil_PYTHON_THREADS)
/*  __THREAD__ is the old macro to activate some thread support */
# if !defined(__THREAD__)
#   define __THREAD__ 1
# endif
#endif

#ifdef __THREAD__
# include "pythread.h"
  class Guard {
    PyThread_type_lock &mutex_;

  public:
    Guard(PyThread_type_lock & mutex) : mutex_(mutex) {
      PyThread_acquire_lock(mutex_, WAIT_LOCK);
    }

    ~Guard() {
      PyThread_release_lock(mutex_);
    }
  };
# define alaqil_GUARD(mutex) Guard _guard(mutex)
#else
# define alaqil_GUARD(mutex)
#endif

  /* director base class */
  class Director {
  private:
    /* pointer to the wrapped python object */
    PyObject *alaqil_self;
    /* flag indicating whether the object is owned by python or c++ */
    mutable bool alaqil_disown_flag;

    /* decrement the reference count of the wrapped python object */
    void alaqil_decref() const {
      if (alaqil_disown_flag) {
        alaqil_PYTHON_THREAD_BEGIN_BLOCK;
        Py_DECREF(alaqil_self);
        alaqil_PYTHON_THREAD_END_BLOCK;
      }
    }

  public:
    /* wrap a python object. */
    Director(PyObject *self) : alaqil_self(self), alaqil_disown_flag(false) {
    }

    /* discard our reference at destruction */
    virtual ~Director() {
      alaqil_decref();
    }

    /* return a pointer to the wrapped python object */
    PyObject *alaqil_get_self() const {
      return alaqil_self;
    }

    /* acquire ownership of the wrapped python object (the sense of "disown" is from python) */
    void alaqil_disown() const {
      if (!alaqil_disown_flag) {
        alaqil_disown_flag=true;
        alaqil_incref();
      }
    }

    /* increase the reference count of the wrapped python object */
    void alaqil_incref() const {
      if (alaqil_disown_flag) {
        Py_INCREF(alaqil_self);
      }
    }

    /* methods to implement pseudo protected director members */
    virtual bool alaqil_get_inner(const char * /* alaqil_protected_method_name */) const {
      return true;
    }

    virtual void alaqil_set_inner(const char * /* alaqil_protected_method_name */, bool /* alaqil_val */) const {
    }

  /* ownership management */
  private:
    typedef std::map<void *, GCItem_var> alaqil_ownership_map;
    mutable alaqil_ownership_map alaqil_owner;
#ifdef __THREAD__
    static PyThread_type_lock alaqil_mutex_own;
#endif

  public:
    template <typename Type>
    void alaqil_acquire_ownership_array(Type *vptr) const {
      if (vptr) {
        alaqil_GUARD(alaqil_mutex_own);
        alaqil_owner[vptr] = new GCArray_T<Type>(vptr);
      }
    }

    template <typename Type>
    void alaqil_acquire_ownership(Type *vptr) const {
      if (vptr) {
        alaqil_GUARD(alaqil_mutex_own);
        alaqil_owner[vptr] = new GCItem_T<Type>(vptr);
      }
    }

    void alaqil_acquire_ownership_obj(void *vptr, int own) const {
      if (vptr && own) {
        alaqil_GUARD(alaqil_mutex_own);
        alaqil_owner[vptr] = new GCItem_Object(own);
      }
    }

    int alaqil_release_ownership(void *vptr) const {
      int own = 0;
      if (vptr) {
        alaqil_GUARD(alaqil_mutex_own);
        alaqil_ownership_map::iterator iter = alaqil_owner.find(vptr);
        if (iter != alaqil_owner.end()) {
          own = iter->second->get_own();
          alaqil_owner.erase(iter);
        }
      }
      return own;
    }

    template <typename Type>
    static PyObject *alaqil_pyobj_disown(PyObject *pyobj, PyObject *alaqilUNUSEDPARM(args)) {
      alaqilPyObject *sobj = (alaqilPyObject *)pyobj;
      sobj->own = 0;
      Director *d = alaqil_DIRECTOR_CAST(reinterpret_cast<Type *>(sobj->ptr));
      if (d)
        d->alaqil_disown();
      return PyWeakref_NewProxy(pyobj, NULL);
    }
  };

#ifdef __THREAD__
  PyThread_type_lock Director::alaqil_mutex_own = PyThread_allocate_lock();
#endif
}

#endif
