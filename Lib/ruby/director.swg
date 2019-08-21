/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that Ruby proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

/*
  Use -Dalaqil_DIRECTOR_NOUEH if you prefer to avoid the use of the
  Undefined Exception Handler provided by alaqil.
*/
#ifndef alaqil_DIRECTOR_NOUEH
#ifndef alaqil_DIRECTOR_UEH
#define alaqil_DIRECTOR_UEH
#endif
#endif

#include <string>
#include <iostream>
#include <exception>
#include <map>

# define alaqil_DIRECTOR_CAST(ARG) dynamic_cast<alaqil::Director *>(ARG)

namespace alaqil {

  /* memory handler */
  struct GCItem {
    virtual ~GCItem() {
    }

    virtual alaqil_ruby_owntype get_own() const {
      alaqil_ruby_owntype own = {0, 0};
      return own;
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

    GCItem *operator->() const {
      return _item;
    }

  private:
    GCItem *_item;
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

  struct GCItem_Object : GCItem {
    GCItem_Object(alaqil_ruby_owntype own) : _own(own) {
    }

    virtual ~GCItem_Object() {
    }

    alaqil_ruby_owntype get_own() const {
      return _own;
    }

  private:
    alaqil_ruby_owntype _own;
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


  /* body args */
  struct body_args {
    VALUE recv;
    ID id;
    int argc;
    VALUE *argv;
  };

  /* Base class for director exceptions */
  class DirectorException : public std::exception {
  protected:
    VALUE alaqil_error;
    std::string alaqil_msg;
  protected:
    DirectorException(VALUE error) : alaqil_error(error) {
    }

    DirectorException(VALUE error, const char *hdr, const char *msg ="") : alaqil_error(error), alaqil_msg(hdr) {
      if (msg[0]) {
	alaqil_msg += " ";
	alaqil_msg += msg;
      }
      if (alaqil_msg.size()) {
	VALUE str = rb_str_new(alaqil_msg.data(), alaqil_msg.size());
	alaqil_error = rb_exc_new3(error, str);
      } else {
	alaqil_error = error;
      }
    }

  public:
    virtual ~DirectorException() throw() {
    }

    VALUE getType() const {
      return CLASS_OF(alaqil_error);
    }

    VALUE getError() const {
      return alaqil_error;
    }

    /* Deprecated, use what() instead */
    const std::string& getMessage() const {
      return alaqil_msg;
    }

    const char *what() const throw() {
      return alaqil_msg.c_str();
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
		<< "Ruby interpreter traceback:" << std::endl;
      std::cerr << std::endl;
      std::cerr << "This exception was caught by the alaqil unexpected exception handler." << std::endl
		<< "Try using %feature(\"director:except\") to avoid reaching this point." << std::endl
		<< std::endl
		<< "Exception is being re-thrown, program will like abort/terminate." << std::endl;
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


  /* Type mismatch in the return value from a Ruby method call */
  class DirectorTypeMismatchException : public DirectorException {
  public:
    DirectorTypeMismatchException(VALUE error, const char *msg="")
      : DirectorException(error, "alaqil director type mismatch", msg) {
    }

    DirectorTypeMismatchException(const char *msg="")
      : DirectorException(rb_eTypeError, "alaqil director type mismatch", msg) {
    }

    static void raise(VALUE error, const char *msg) {
      throw DirectorTypeMismatchException(error, msg);
    }

    static void raise(const char *msg) {
      throw DirectorTypeMismatchException(msg);
    }
  };

  /* Any Ruby exception that occurs during a director method call */
  class DirectorMethodException : public DirectorException {
  public:
    DirectorMethodException(VALUE error)
      : DirectorException(error) {
    }

    DirectorMethodException(const char *msg = "")
      : DirectorException(rb_eRuntimeError, "alaqil director method error.", msg) {
    }

    static void raise(VALUE error) {
      throw DirectorMethodException(error);
    }
  };

  /* Attempted to call a pure virtual method via a director method */
  class DirectorPureVirtualException : public DirectorException
  {
  public:
    DirectorPureVirtualException(const char *msg = "")
      : DirectorException(rb_eRuntimeError, "alaqil director pure virtual method called", msg) {
    }

    static void raise(const char *msg) {
      throw DirectorPureVirtualException(msg);
    }
  };

  /* Simple thread abstraction for pthreads on win32 */
#ifdef __THREAD__
# define __PTHREAD__
# if defined(_WIN32) || defined(__WIN32__)
#  define pthread_mutex_lock EnterCriticalSection
#  define pthread_mutex_unlock LeaveCriticalSection
#  define pthread_mutex_t CRITICAL_SECTION
#  define alaqil_MUTEX_INIT(var) var
# else
#  include <pthread.h>
#  define alaqil_MUTEX_INIT(var) var = PTHREAD_MUTEX_INITIALIZER
# endif
#endif

#ifdef  __PTHREAD__
  struct Guard {
    pthread_mutex_t *_mutex;

    Guard(pthread_mutex_t &mutex) : _mutex(&mutex) {
      pthread_mutex_lock(_mutex);
    }

    ~Guard() {
      pthread_mutex_unlock(_mutex);
    }
  };
# define alaqil_GUARD(mutex) Guard _guard(mutex)
#else
# define alaqil_GUARD(mutex)
#endif

  /* director base class */
  class Director {
  private:
    /* pointer to the wrapped Ruby object */
    VALUE alaqil_self;
    /* flag indicating whether the object is owned by Ruby or c++ */
    mutable bool alaqil_disown_flag;

  public:
    /* wrap a Ruby object. */
    Director(VALUE self) : alaqil_self(self), alaqil_disown_flag(false) {
    }

    /* discard our reference at destruction */
    virtual ~Director() {
    }

    /* return a pointer to the wrapped Ruby object */
    VALUE alaqil_get_self() const {
      return alaqil_self;
    }

    /* acquire ownership of the wrapped Ruby object (the sense of "disown" is from Ruby) */
    void alaqil_disown() const {
      if (!alaqil_disown_flag) {
        alaqil_disown_flag = true;
      }
    }

  /* ownership management */
  private:
    typedef std::map<void *, GCItem_var> alaqil_ownership_map;
    mutable alaqil_ownership_map alaqil_owner;
#ifdef __PTHREAD__
    static pthread_mutex_t alaqil_mutex_own;
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
    void alaqil_acquire_ownership(Type *vptr)  const {
      if (vptr) {	
	alaqil_GUARD(alaqil_mutex_own);
	alaqil_owner[vptr] = new GCItem_T<Type>(vptr);
      }
    }

    void alaqil_acquire_ownership_obj(void *vptr, alaqil_ruby_owntype own) const {
      if (vptr && own.datafree) {
	alaqil_GUARD(alaqil_mutex_own);
	alaqil_owner[vptr] = new GCItem_Object(own);
      }
    }

    alaqil_ruby_owntype alaqil_release_ownership(void *vptr) const {
      alaqil_ruby_owntype own = {0, 0};
      if (vptr) {
	alaqil_GUARD(alaqil_mutex_own);
	alaqil_ownership_map::iterator iter = alaqil_owner.find(vptr);
	if (iter != alaqil_owner.end()) {
	  own.datafree = iter->second->get_own().datafree;
	  alaqil_owner.erase(iter);
	}
      }
      return own;
    }
  };
}

