/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that Ocaml proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

#include <string>
#include <exception>

# define alaqil_DIRECTOR_CAST(ARG) dynamic_cast<alaqil::Director *>(ARG)

namespace alaqil {
  /* base class for director exceptions */
  class DirectorException : public std::exception {
    protected:
      std::string alaqil_msg;

    public:
      DirectorException(const char *msg="") : alaqil_msg(msg) {
      }

      virtual ~DirectorException() throw() {
      }

      const char *what() const throw() {
        return alaqil_msg.c_str();
      }
  };

  /* type mismatch in the return value from a Ocaml method call */
  class DirectorTypeMismatchException : public DirectorException {
    public:
      DirectorTypeMismatchException(const char *msg="") : DirectorException(msg) {
      }
  };

  /* any Ocaml exception that occurs during a director method call */
  class DirectorMethodException : public DirectorException {};

  /* attempt to call a pure virtual method via a director method */
  class DirectorPureVirtualException : public DirectorException {
    public:
      DirectorPureVirtualException(const char *msg="") : DirectorException(msg) {
      }

      static void raise(const char *msg) {
        throw DirectorPureVirtualException(msg);
      }
  };

  /* simple thread abstraction for pthreads on win32 */
#ifdef __THREAD__
#define __PTHREAD__
#if defined(_WIN32) || defined(__WIN32__)
#define pthread_mutex_lock EnterCriticalSection
#define pthread_mutex_unlock LeaveCriticalSection
#define pthread_mutex_t CRITICAL_SECTION
#define MUTEX_INIT(var) CRITICAL_SECTION var
#else
#include <pthread.h>
#define MUTEX_INIT(var) pthread_mutex_t var = PTHREAD_MUTEX_INITIALIZER
#endif
#endif

  /* director base class */
  class Director {
    private:
      /* pointer to the wrapped ocaml object */
      CAML_VALUE alaqil_self;
      /* flag indicating whether the object is owned by ocaml or c++ */
      mutable bool alaqil_disown_flag;

    public:
      /* wrap a ocaml object. */
      Director(CAML_VALUE self) : alaqil_self(self), alaqil_disown_flag(false) {
        caml_register_global_root(&alaqil_self);
      }

      /* discard our reference at destruction */
      virtual ~Director() {
        caml_remove_global_root(&alaqil_self);
        alaqil_disown();
        // Disown is safe here because we're just divorcing a reference that points to us.
      }

      /* return a pointer to the wrapped ocaml object */
      CAML_VALUE alaqil_get_self() const {
	  return alaqil_self;
      }

      /* acquire ownership of the wrapped ocaml object (the sense of "disown" is from ocaml) */
      void alaqil_disown() const {
        if (!alaqil_disown_flag) {
          alaqil_disown_flag=true;
          caml_callback(*caml_named_value("caml_obj_disown"),alaqil_self);
        }
      }
  };
}

