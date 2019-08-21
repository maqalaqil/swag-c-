// Vectors

%fragment("StdVectorTraits","header",fragment="StdSequenceTraits")
%{
  namespace alaqil {
    template <class T>
    struct traits_asptr<std::vector<T> >  {
      static int asptr(const octave_value& obj, std::vector<T> **vec) {
	return traits_asptr_stdseq<std::vector<T> >::asptr(obj, vec);
      }
    };
    
    template <class T>
    struct traits_from<std::vector<T> > {
      static octave_value from(const std::vector<T>& vec) {
	return traits_from_stdseq<std::vector<T> >::from(vec);
      }
    };
  }
%}

#define %alaqil_vector_methods(Type...) %alaqil_sequence_methods(Type)
#define %alaqil_vector_methods_val(Type...) %alaqil_sequence_methods_val(Type);

%include <std/std_vector.i>

