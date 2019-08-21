%module typemap_documentation

// A place for checking that documented typemaps are working.
// The UTL languages are the only ones that are consistent enough to support these generic typemap functions.
// These are in the Typemaps.html chapter.

%inline %{
class Foo {
public:
  int x;
};

class Bar {
public:
  int y;
};
%}

#if defined(alaqilUTL)
%typemap(in) Foo * {
  if (!alaqil_IsOK(alaqil_ConvertPtr($input, (void **) &$1, $1_descriptor, 0))) {
    alaqil_exception_fail(alaqil_TypeError, "in method '$symname', expecting type Foo");
  }
}
#endif

%inline %{
int GrabVal(Foo *f) {
  return f->x;
}
%}


#if defined(alaqilUTL)
%typemap(in) Foo * {
  if (!alaqil_IsOK(alaqil_ConvertPtr($input, (void **) &$1, $1_descriptor, 0))) {
    Bar *temp;
    if (!alaqil_IsOK(alaqil_ConvertPtr($input, (void **) &temp, $descriptor(Bar *), 0))) {
      alaqil_exception_fail(alaqil_TypeError, "in method '$symname', expecting type Foo or Bar");
    }
    $1 = (Foo *)temp;
  }
}
#endif

%inline %{
int GrabValFooBar(Foo *f) {
  return f->x;
}
%}
