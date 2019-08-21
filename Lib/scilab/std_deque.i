/*
 *
 * C++ type : STL deque
 * Scilab type : matrix (for primitive types) or list (for pointer types)
 *
*/

%fragment("StdDequeTraits", "header", fragment="StdSequenceTraits")
%{
  namespace alaqil {
    template <class T>
    struct traits_asptr<std::deque<T> >  {
      static int asptr(const alaqilSciObject &obj, std::deque<T> **deq) {
        return traits_asptr_stdseq<std::deque<T> >::asptr(obj, deq);
      }
    };

    template <class T>
    struct traits_from<std::deque<T> > {
      static alaqilSciObject from(const std::deque<T>& deq) {
	      return traits_from_stdseq<std::deque<T> >::from(deq);
      }
    };
  }
%}


#define %alaqil_deque_methods(Type...) %alaqil_sequence_methods(Type)
#define %alaqil_deque_methods_val(Type...) %alaqil_sequence_methods_val(Type);

%include <std/std_deque.i>
