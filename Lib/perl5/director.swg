/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that Perl proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

#ifndef alaqil_DIRECTOR_PERL_HEADER_
#define alaqil_DIRECTOR_PERL_HEADER_

#include <string>
#include <iostream>
#include <exception>
#include <vector>
#include <map>


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

    GCItem *operator->() const {
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
  public:
    virtual SV *getNative() const = 0;
  };

  /* exceptions emitted by Perl */
  class DirectorMethodException : public DirectorException {
  protected:
    SV *err;
  public:
    DirectorMethodException(SV *sv = sv_mortalcopy(ERRSV)) : err(sv) {
      SvREFCNT_inc(err);
    }

    const char *what() const throw() {
      return SvPV_nolen(err);
    }

    SV *getNative() const {
      return sv_2mortal(newSVsv(err));
    }

    static void raise(SV *sv) {
      throw DirectorMethodException(sv);
    }
  };

  /* exceptions emitted by wrap code */
  class DirectorWrapException : public DirectorException {
  protected:
    std::string msg;
    DirectorWrapException(const char *str) : msg(str) {
    }

  public:
    virtual ~DirectorWrapException() throw() {
    }

    const char *what() const throw() {
      return msg.c_str();
    }

    virtual SV *getNative() const {
      return sv_2mortal(newSVpvn(msg.data(), msg.size()));
    }
  };

  class DirectorTypeMismatchException : public DirectorWrapException {
  public:
    DirectorTypeMismatchException(const char *str) : DirectorWrapException(str) {
    }

    static void raise(const char *type, const char *msg) {
      std::string err = std::string(type);
      err += ": ";
      err += msg;
      throw DirectorTypeMismatchException(err.c_str());
    }
  };

  class DirectorPureVirtualException : public DirectorWrapException {
  public:
    DirectorPureVirtualException(const char *name)
      : DirectorWrapException("alaqil director pure virtual method called: ") {
      msg += name;
    }

    static void raise(const char *name) {
      throw DirectorPureVirtualException(name);
    }
  };

  /* director base class */
  class Director {
  private:
    /* pointer to the wrapped perl object */
    SV *alaqil_self;
    /* class of wrapped perl object */
    std::string alaqil_class;
    /* flag indicating whether the object is owned by perl or c++ */
    mutable bool alaqil_disown_flag;

    /* decrement the reference count of the wrapped perl object */
    void alaqil_decref() const {
      if (alaqil_disown_flag) {
        SvREFCNT_dec(alaqil_self);
      }
    }

  public:
    /* wrap a Perl object. */
    Director(SV *pkg) : alaqil_disown_flag(false) {
      STRLEN len;
      char *str = SvPV(pkg, len);
      alaqil_class = std::string(str, len);
      alaqil_self = newRV_inc((SV *)newHV());
    }

    /* discard our reference at destruction */
    virtual ~Director() {
      alaqil_decref();
    }

    /* return a pointer to the wrapped Perl object */
    SV *alaqil_get_self() const {
      return alaqil_self;
    }

    const char *alaqil_get_class() const {
      return alaqil_class.c_str();
    }

    /* acquire ownership of the wrapped Perl object (the sense of "disown" is from perl) */
    void alaqil_disown() const {
      if (!alaqil_disown_flag) {
        alaqil_disown_flag=true;
        alaqil_incref();
      }
    }

    /* increase the reference count of the wrapped Perl object */
    void alaqil_incref() const {
      if (alaqil_disown_flag) {
        SvREFCNT_inc(alaqil_self);
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

  public:
    template <typename Type>
    void alaqil_acquire_ownership_array(Type *vptr) const {
      if (vptr) {
        alaqil_owner[vptr] = new GCArray_T<Type>(vptr);
      }
    }

    template <typename Type>
    void alaqil_acquire_ownership(Type *vptr) const {
      if (vptr) {
        alaqil_owner[vptr] = new GCItem_T<Type>(vptr);
      }
    }

    void alaqil_acquire_ownership_obj(void *vptr, int own) const {
      if (vptr && own) {
        alaqil_owner[vptr] = new GCItem_Object(own);
      }
    }

    int alaqil_release_ownership(void *vptr) const {
      int own = 0;
      if (vptr) {
        alaqil_ownership_map::iterator iter = alaqil_owner.find(vptr);
        if (iter != alaqil_owner.end()) {
          own = iter->second->get_own();
          alaqil_owner.erase(iter);
        }
      }
      return own;
    }
  };

}

#endif

