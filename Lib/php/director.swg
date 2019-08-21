/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that PHP proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

#ifndef alaqil_DIRECTOR_PHP_HEADER_
#define alaqil_DIRECTOR_PHP_HEADER_

#include <string>
#include <exception>
#include <map>

namespace alaqil {

  /* memory handler */
  struct GCItem {
    virtual ~GCItem() {
    }

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

  class Director {
    protected:
      // "mutable" so we can get a non-const pointer to it in const methods.
      mutable zval alaqil_self;
      typedef std::map<void *, GCItem_var> alaqil_ownership_map;
      mutable alaqil_ownership_map alaqil_owner;
    public:
      Director(zval *self) {
        ZVAL_COPY_VALUE(&alaqil_self, self);
      }

      static bool alaqil_is_overridden_method(const char *cname, const char *lc_fname) {
        bool result = false;
        zend_string * cname_str = zend_string_init(cname, strlen(cname), 0);
        zend_class_entry *ce = zend_lookup_class(cname_str);
        if (ce) {
          zval * mptr = zend_hash_str_find(&ce->function_table, lc_fname, strlen(lc_fname));
          if (mptr) {
            // common.scope points to zend_class_entry for the declaring class,
            // and there's only one of those per class, so we can just use a
            // pointer compare here.
            result = Z_FUNC_P(mptr)->common.scope != ce;
          }
        }
        zend_string_release(cname_str);
        return result;
      }

      template <typename Type>
      void alaqil_acquire_ownership(Type *vptr) const {
        if (vptr) {
          alaqil_owner[vptr] = new GCItem_T<Type>(vptr);
        }
      }
  };

  /* base class for director exceptions */
  class DirectorException : public std::exception {
  protected:
    std::string alaqil_msg;
  public:
    DirectorException(int code, const char *hdr, const char *msg) : alaqil_msg(hdr) {
      if (msg && msg[0]) {
        alaqil_msg += " ";
        alaqil_msg += msg;
      }
      alaqil_ErrorCode() = code;
      alaqil_ErrorMsg() = alaqil_msg.c_str();
    }

    virtual ~DirectorException() throw() {
    }

    const char *what() const throw() {
      return alaqil_msg.c_str();
    }

    static void raise(int code, const char *hdr, const char *msg) {
      throw DirectorException(code, hdr, msg);
    }
  };

  /* attempt to call a pure virtual method via a director method */
  class DirectorPureVirtualException : public DirectorException {
  public:
    DirectorPureVirtualException(const char *msg)
      : DirectorException(E_ERROR, "alaqil director pure virtual method called", msg) {
    }

    static void raise(const char *msg) {
      throw DirectorPureVirtualException(msg);
    }
  };

  /* any php exception that occurs during a director method call */
  class DirectorMethodException : public DirectorException
  {
  public:
    DirectorMethodException()
      : DirectorException(E_ERROR, "alaqil director method error", NULL) {
    }

    DirectorMethodException(const char *msg)
      : DirectorException(E_ERROR, "alaqil director method error", msg) {
    }

    static void raise(const char *msg) {
      throw DirectorMethodException(msg);
    }
  };
}

#endif
