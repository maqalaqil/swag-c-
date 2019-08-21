/*
 *
 * C++ type : STL list
 * Scilab type : matrix (for primitive types) or list (for pointer types)
 *
*/

%fragment("StdListTraits", "header", fragment="StdSequenceTraits")
%{
  namespace alaqil {
    template <class T >
    struct traits_asptr<std::list<T> >  {
      static int asptr(alaqilSciObject obj, std::list<T> **lis) {
	      return traits_asptr_stdseq<std::list<T> >::asptr(obj, lis);
      }
    };

    template <class T>
    struct traits_from<std::list<T> > {
      static alaqilSciObject from(const std::list<T> &lis) {
	      return traits_from_stdseq<std::list<T> >::from(lis);
      }
    };
  }
%}

#define %alaqil_list_methods(Type...) %alaqil_sequence_methods(Type)
#define %alaqil_list_methods_val(Type...) %alaqil_sequence_methods_val(Type);

%include <std/std_list.i>
