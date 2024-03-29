%module derived_byvalue

#ifdef alaqilOCAML
%warnfilter(alaqilWARN_PARSE_KEYWORD) method;
#endif

%inline %{

struct Foo {
  int x;

  // this works
  int rmethod(const Foo& f) { return f.x; }

  // this doesn't when DerFoo (below) is introduced
  int method(Foo f) { return f.x; }
};

struct Bar {
   Foo   a;
   struct Foo b;
};

/*
  When the next derived class is declared, the 
  following bad method is generated

  static void *_DerFooTo_Foo(void *x) {   // **** bad ****
    return (void *)((Foo)  ((DerFoo) x));
  }

  static void *_p_DerFooTo_p_Foo(void *x) {   // *** good ***
    return (void *)((Foo *)  ((DerFoo *) x));
  }
  
  if the derived class is deleted, it works again 

  if the previous Foo::method is deleted, it works again

 */
struct DerFoo : Foo {
};

/*
  The problem is caused by accidentally remembering a object value type
  instead of an object pointer type.
  During the course of alaqiling a file, several calls to alaqilType_remember()
  or alaqilType_remember_clientdata() will be made.
  When the alaqilType_emit_type_table() function is called it emits all the
  type conversion functions.
  
  If a object type exists in the alaqilType table, you get this error.

  You can view the alaqilType table, with a #define DEBUG at the top of
  Source/alaqil/typesys.c

  When run you get an output like this:

---r_mangled---
Hash {
    '_p_Bar' : Hash {
        'p.Bar' : _p_Bar, 
    }
, 
    '_p_DerFoo' : Hash {
        'p.DerFoo' : _p_DerFoo, 
    }
, 
    '_p_Foo' : Hash {
        'r.Foo' : _p_Foo, 
        'p.Foo' : _p_Foo, 
    }
, 
    '_Foo' : Hash {
        'Foo' : _Foo, 
    }
, 
}
....

  The last field ('_Foo') is an object type and caused the error.
  It can be fixed either by checking all the calls to alaqilType_remember()
  and by checking the typemaps.
  The typemap code also calls alaqilType_remember(), if your typemaps
  defined an object type, it will be added into the alaqilType table.
  its normally a 
    alaqil_ConvertPtr(....$descriptor...)
  when it should have been a $&descriptor or $*descriptor
    
  Commenting out all your object typemaps (and typecheck fns) may help
  isolate it.

*/
#
%}
