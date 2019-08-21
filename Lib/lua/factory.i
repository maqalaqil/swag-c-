/*
	A modification of factory.swg from the generic UTL library.
*/

%include <typemaps/alaqilmacros.swg>

%define %_factory_dispatch(Type) 
if (!dcast) {
  Type *dobj = dynamic_cast<Type *>($1);
  if (dobj) {
    dcast = 1;
    alaqil_NewPointerObj(L, dobj, $descriptor(Type *), $owner); alaqil_arg++;
  }   
}%enddef

%define %factory(Method,Types...)
%typemap(out) Method {
  int dcast = 0;
  %formacro(%_factory_dispatch, Types)
  if (!dcast) {
    alaqil_NewPointerObj(L, $1, $descriptor, $owner); alaqil_arg++;
  }
}%enddef
