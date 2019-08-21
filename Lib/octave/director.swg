/* -----------------------------------------------------------------------------
 * director.swg
 *
 * This file contains support for director classes so that Octave proxy
 * methods can be called from C++.
 * ----------------------------------------------------------------------------- */

# define alaqil_DIRECTOR_CAST(ARG) dynamic_cast<alaqil::Director *>(ARG)

#include <exception>

namespace alaqil {

  class Director {
    octave_alaqil_type *self;
    bool alaqil_disowned;

    Director(const Director &x);
    Director &operator=(const Director &rhs);
  public:

    Director(void *vptr):self(0), alaqil_disowned(false) {
      set_rtdir(vptr, this);
    }

    ~Director() {
      alaqil_director_destroyed(self, this);
      if (alaqil_disowned)
	self->decref();
    }

    void alaqil_set_self(octave_alaqil_type *new_self) {
      assert(!alaqil_disowned);
      self = new_self;
    }

    octave_alaqil_type *alaqil_get_self() const {
      return self;
    }

    void alaqil_disown() {
      if (alaqil_disowned)
	return;
      alaqil_disowned = true;
      self->incref();
    }
  };

  // Base class for director exceptions.
  class DirectorException : public std::exception {
  public:
    static void raise(const char *msg) {
      // ... todo
      throw DirectorException();
    }

    static void raise(const octave_value &ov, const char *msg) {
      // ... todo
      raise(msg);
    }
  };

  class DirectorTypeMismatchException : public DirectorException {
  public:
    static void raise(const char *msg) {
      // ... todo
      throw DirectorTypeMismatchException();
    }

    static void raise(const octave_value &ov, const char *msg) {
      // ... todo
      raise(msg);
    }
  };

  class DirectorPureVirtualException : public DirectorException {
  public:
    static void raise(const char *msg) {
      // ... todo
      throw DirectorPureVirtualException();
    }

    static void raise(const octave_value &ov, const char *msg) {
      // ... todo
      raise(msg);
    }
  };

  alaqilINTERN rtdir_map *get_rtdir_map() {
    static alaqil_module_info *module = 0;
    if (!module)
      module = alaqil_GetModule(0);
    if (!module)
      return 0;
    if (!module->clientdata)
      module->clientdata = new rtdir_map;
    return (rtdir_map *) module->clientdata;
  }

  alaqilINTERNINLINE void set_rtdir(void *vptr, Director *d) {
    rtdir_map *rm = get_rtdir_map();
    if (rm)
      (*rm)[vptr] = d;
  }

  alaqilINTERNINLINE void erase_rtdir(void *vptr) {
    rtdir_map *rm = get_rtdir_map();
    if (rm)
      (*rm).erase(vptr);
  }

  alaqilINTERNINLINE Director *get_rtdir(void *vptr) {
    rtdir_map *rm = get_rtdir_map();
    if (!rm)
      return 0;
    rtdir_map::const_iterator pos = rm->find(vptr);
    Director *rtdir = (pos != rm->end())? pos->second : 0;
    return rtdir;
  }

  alaqilRUNTIME void alaqil_director_destroyed(octave_alaqil_type *self, Director *d) {
    self->director_destroyed(d);
  }

  alaqilRUNTIME octave_alaqil_type *alaqil_director_get_self(Director *d) {
    return d->alaqil_get_self();
  }

  alaqilRUNTIME void alaqil_director_set_self(Director *d, octave_alaqil_type *self) {
    d->alaqil_set_self(self);
  }

}

alaqilRUNTIME void alaqil_acquire_ownership(void *vptr) {
  //  assert(0);
  // ... todo
}

alaqilRUNTIME void alaqil_acquire_ownership_array(void *vptr) {
  //  assert(0);
  // ... todo
}

alaqilRUNTIME void alaqil_acquire_ownership_obj(void *vptr, int own) {
  //  assert(0);
  // ... todo
}
