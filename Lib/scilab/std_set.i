/*
 *
 * C++ type : STL set
 * Scilab type : matrix (for primitive types) or list (for pointer types)
 *
*/

%fragment("StdSetTraits", "header", fragment="StdSequenceTraits")
%{
  namespace alaqil {
    template <class T>
    struct traits_asptr<std::set<T> >  {
      static int asptr(const alaqilSciObject &obj, std::set<T> **set) {
        return traits_asptr_stdseq<std::set<T> >::asptr(obj, set);
      }
    };

    template <class T>
    struct traits_from<std::set<T> > {
      static alaqilSciObject from(const std::set<T>& set) {
        return traits_from_stdseq<std::set<T> >::from(set);
      }
    };
  }
%}


#define %alaqil_set_methods(Type...) %alaqil_sequence_methods(Type)
#define %alaqil_set_methods_val(Type...) %alaqil_sequence_methods_val(Type);

%include <std/std_set.i>

