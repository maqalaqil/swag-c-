%module typemap_array_qualifiers

%define CLEAR_alaqilTYPE_TYPEMAPS
%typemap(in)
   alaqilTYPE,
   alaqilTYPE *,
   alaqilTYPE *const,
   alaqilTYPE *const&,
   const alaqilTYPE *,
   const alaqilTYPE *const,
   const alaqilTYPE *const&,
   const volatile alaqilTYPE *,
   const volatile alaqilTYPE *const,
   const volatile alaqilTYPE *const&,
   alaqilTYPE [],
   alaqilTYPE [ANY],
   const alaqilTYPE [],
   const alaqilTYPE [ANY],
   const volatile alaqilTYPE [],
   const volatile alaqilTYPE [ANY],
   alaqilTYPE &,
   const alaqilTYPE &,
   const volatile alaqilTYPE &
{
%#error Incorrect typemap for $symname: $type
}
%enddef

%inline %{
  typedef struct {
    int a;
  } SomeType;
  typedef SomeType myarray[3];
  typedef const SomeType myconstarray[4];
  typedef volatile SomeType ** mycrazyarray[5];
  extern "C" {
    typedef volatile SomeType (mycrazyfunc)(SomeType);
    typedef volatile SomeType (*mycrazyfuncptr)(SomeType);
  }
%}

CLEAR_alaqilTYPE_TYPEMAPS;
%typemap(in) alaqilTYPE [ANY] {
$1 = 0;
/* Correct typemap for $symname: $type */
}
%inline %{
  void func1a(myarray x) {}
  void func1b(volatile myarray x) {}
%}

CLEAR_alaqilTYPE_TYPEMAPS;
%typemap(in) const alaqilTYPE [ANY] {
$1 = 0;
/* Correct typemap for $symname: $type */
}
%typemap(in) const volatile alaqilTYPE [ANY] {
$1 = 0;
/* Correct typemap for $symname: $type */
}
%inline %{
  void func2a(const myarray x) {}
  void func2b(const myconstarray x) {}
  void func2c(const volatile myconstarray x) {}
%}

CLEAR_alaqilTYPE_TYPEMAPS;
%typemap(in) volatile alaqilTYPE **const [ANY] {
$1 = 0;
/* Correct typemap for $symname: $type */
}
%typemap(in) volatile alaqilTYPE **const [ANY][ANY] {
$1 = 0;
/* Correct typemap for $symname: $type */
}
%inline %{
  void func3a(const mycrazyarray x, const mycrazyarray y[7]) {}
%}

CLEAR_alaqilTYPE_TYPEMAPS;
%typemap(in) alaqilTYPE (*const) (ANY) {
$1 = 0;
/* Correct typemap for $symname: $type */
}
%inline %{
  void func4a(mycrazyfunc *const x, const mycrazyfuncptr y) {}
%}
