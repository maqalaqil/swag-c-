/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that Go proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

#include <exception>
#include <map>

namespace alaqil {

  class DirectorException : public std::exception {
  };
}

/* Handle memory management for directors.  */

namespace {
  struct GCItem {
    virtual ~GCItem() {}
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

    GCItem* operator->() {
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
}

class alaqil_memory {
public:
  template <typename Type>
  void alaqil_acquire_pointer(Type* vptr) {
    if (vptr) {
      alaqil_owner[vptr] = new GCItem_T<Type>(vptr);
    }
  }
private:
  typedef std::map<void *, GCItem_var> alaqil_ownership_map;
  alaqil_ownership_map alaqil_owner;
};

template <typename Type>
static void alaqil_acquire_pointer(alaqil_memory** pmem, Type* ptr) {
  if (!pmem) {
    *pmem = new alaqil_memory;
  }
  (*pmem)->alaqil_acquire_pointer(ptr);
}
