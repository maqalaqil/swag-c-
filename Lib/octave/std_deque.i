// Deques

%fragment("StdDequeTraits","header",fragment="StdSequenceTraits")
%{
  namespace alaqil {
    template <class T>
    struct traits_asptr<std::deque<T> >  {
      static int asptr(octave_value obj, std::deque<T>  **vec) {
	return traits_asptr_stdseq<std::deque<T> >::asptr(obj, vec);
      }
    };

    template <class T>
    struct traits_from<std::deque<T> > {
      static octave_value from(const std::deque<T>& vec) {
	return traits_from_stdseq<std::deque<T> >::from(vec);
      }
    };
  }
%}

#define %alaqil_deque_methods(Type...) %alaqil_sequence_methods(Type)
#define %alaqil_deque_methods_val(Type...) %alaqil_sequence_methods_val(Type);

%include <std/std_deque.i>
