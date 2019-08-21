/*
  Vectors + allocators
*/

%fragment("StdVectorATraits","header",fragment="StdSequenceTraits")
%{
  namespace alaqil {
    template <class T, class A>
      struct traits_asptr<std::vector<T,A> >  {
      typedef std::vector<T,A> vector_type;
      typedef T value_type;
      static int asptr(PyObject *obj, vector_type **vec) {
	return traits_asptr_stdseq<vector_type>::asptr(obj, vec);
      }
    };

    template <class T, class A>
    struct traits_from<std::vector<T,A> > {
      typedef std::vector<T,A> vector_type;
      static PyObject *from(const vector_type& vec) {
	return traits_from_stdseq<vector_type>::from(vec);
      }
    };
  }
%}


#define %alaqil_vector_methods(Type...) %alaqil_sequence_methods(Type)
#define %alaqil_vector_methods_val(Type...) %alaqil_sequence_methods_val(Type);

%include <std/std_vectora.i>
