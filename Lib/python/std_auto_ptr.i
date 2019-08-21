/*
    The typemaps here allow to handle functions returning std::auto_ptr<>,
    which is the most common use of this type. If you have functions taking it
    as parameter, these typemaps can't be used for them and you need to do
    something else (e.g. use shared_ptr<> which alaqil supports fully).
 */

%define %auto_ptr(TYPE)
%typemap (out) std::auto_ptr<TYPE > %{
   %set_output(alaqil_NewPointerObj($1.release(), $descriptor(TYPE *), alaqil_POINTER_OWN | %newpointer_flags));
%}
%template() std::auto_ptr<TYPE >;
%enddef

namespace std {
   template <class T> class auto_ptr {};
} 
