/*
 *
 * C++ type : STL multiset
 * Scilab type : matrix (for primitive types) or list (for pointer types)
 *
*/

%fragment("StdMultisetTraits", "header", fragment="StdSequenceTraits")
%{
  namespace alaqil {
    template <class T>
    struct traits_asptr<std::multiset<T> >  {
      static int asptr(const alaqilSciObject &obj, std::multiset<T> **multiset) {
        return traits_asptr_stdseq<std::multiset<T> >::asptr(obj, multiset);
      }
    };

    template <class T>
    struct traits_from<std::multiset<T> > {
      static alaqilSciObject from(const std::multiset<T>& multiset) {
        return traits_from_stdseq<std::multiset<T> >::from(multiset);
      }
    };
  }
%}

#define %alaqil_multiset_methods(Set...) %alaqil_sequence_methods(Type)
#define %alaqil_multiset_methods_val(Type...) %alaqil_sequence_methods_val(Type);

%include <std/std_multiset.i>
