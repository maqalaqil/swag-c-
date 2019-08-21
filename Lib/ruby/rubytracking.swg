/* -----------------------------------------------------------------------------
 * rubytracking.swg
 *
 * This file contains support for tracking mappings from
 * Ruby objects to C++ objects.  This functionality is needed
 * to implement mark functions for Ruby's mark and sweep
 * garbage collector.
 * ----------------------------------------------------------------------------- */

#ifdef __cplusplus
extern "C" {
#endif

#if !defined(ST_DATA_T_DEFINED)
/* Needs to be explicitly included for Ruby 1.8 and earlier */
#include <st.h>
#endif

/* Ruby 1.8 actually assumes the first case. */
#if SIZEOF_VOIDP == SIZEOF_LONG
#  define alaqil2NUM(v) LONG2NUM((unsigned long)v)
#  define NUM2alaqil(x) (unsigned long)NUM2LONG(x)
#elif SIZEOF_VOIDP == SIZEOF_LONG_LONG
#  define alaqil2NUM(v) LL2NUM((unsigned long long)v)
#  define NUM2alaqil(x) (unsigned long long)NUM2LL(x)
#else
#  error sizeof(void*) is not the same as long or long long
#endif

/* Global hash table to store Trackings from C/C++
   structs to Ruby Objects.
*/
static st_table* alaqil_ruby_trackings = NULL;

static VALUE alaqil_ruby_trackings_count(ANYARGS) {
  return alaqil2NUM(alaqil_ruby_trackings->num_entries);
}


/* Setup a hash table to store Trackings */
alaqilRUNTIME void alaqil_RubyInitializeTrackings(void) {
  /* Create a hash table to store Trackings from C++
     objects to Ruby objects. */

  /* Try to see if some other .so has already created a
     tracking hash table, which we keep hidden in an instance var
     in the alaqil module.
     This is done to allow multiple DSOs to share the same
     tracking table.
  */
  VALUE trackings_value = Qnil;
  /* change the variable name so that we can mix modules
     compiled with older alaqil's - this used to be called "@__trackings__" */
  ID trackings_id = rb_intern( "@__safetrackings__" );
  VALUE verbose = rb_gv_get("VERBOSE");
  rb_gv_set("VERBOSE", Qfalse);
  trackings_value = rb_ivar_get( _malaqil, trackings_id );
  rb_gv_set("VERBOSE", verbose);

  /* The trick here is that we have to store the hash table
  pointer in a Ruby variable. We do not want Ruby's GC to
  treat this pointer as a Ruby object, so we convert it to
  a Ruby numeric value. */
  if (trackings_value == Qnil) {
    /* No, it hasn't.  Create one ourselves */
    alaqil_ruby_trackings = st_init_numtable();
    rb_ivar_set( _malaqil, trackings_id, alaqil2NUM(alaqil_ruby_trackings) );
  } else {
    alaqil_ruby_trackings = (st_table*)NUM2alaqil(trackings_value);
  }

  rb_define_virtual_variable("alaqil_TRACKINGS_COUNT", alaqil_ruby_trackings_count, NULL);
}

/* Add a Tracking from a C/C++ struct to a Ruby object */
alaqilRUNTIME void alaqil_RubyAddTracking(void* ptr, VALUE object) {
  /* Store the mapping to the global hash table. */
  st_insert(alaqil_ruby_trackings, (st_data_t)ptr, object);
}

/* Get the Ruby object that owns the specified C/C++ struct */
alaqilRUNTIME VALUE alaqil_RubyInstanceFor(void* ptr) {
  /* Now lookup the value stored in the global hash table */
  VALUE value;

  if (st_lookup(alaqil_ruby_trackings, (st_data_t)ptr, &value)) {
    return value;
  } else {
    return Qnil;
  }
}

/* Remove a Tracking from a C/C++ struct to a Ruby object.  It
   is very important to remove objects once they are destroyed
   since the same memory address may be reused later to create
   a new object. */
alaqilRUNTIME void alaqil_RubyRemoveTracking(void* ptr) {
  /* Delete the object from the hash table */
  st_delete(alaqil_ruby_trackings, (st_data_t *)&ptr, NULL);
}

/* This is a helper method that unlinks a Ruby object from its
   underlying C++ object.  This is needed if the lifetime of the
   Ruby object is longer than the C++ object. */
alaqilRUNTIME void alaqil_RubyUnlinkObjects(void* ptr) {
  VALUE object = alaqil_RubyInstanceFor(ptr);

  if (object != Qnil) {
    // object might have the T_ZOMBIE type, but that's just
    // because the GC has flagged it as such for a deferred
    // destruction. Until then, it's still a T_DATA object.
    DATA_PTR(object) = 0;
  }
}

/* This is a helper method that iterates over all the trackings
   passing the C++ object pointer and its related Ruby object
   to the passed callback function. */

/* Proxy method to abstract the internal trackings datatype */
static int alaqil_ruby_internal_iterate_callback(void* ptr, VALUE obj, void(*meth)(void* ptr, VALUE obj)) {
  (*meth)(ptr, obj);
  return ST_CONTINUE;
}

alaqilRUNTIME void alaqil_RubyIterateTrackings( void(*meth)(void* ptr, VALUE obj) ) {
  st_foreach(alaqil_ruby_trackings, (int (*)(ANYARGS))&alaqil_ruby_internal_iterate_callback, (st_data_t)meth);
}

#ifdef __cplusplus
}
#endif
