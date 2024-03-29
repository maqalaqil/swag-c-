/*
  Lists
*/

%fragment("StdListTraits","header",fragment="StdSequenceTraits")
%{
  namespace alaqil {
    template <class T >
    struct traits_asptr<std::list<T> >  {
      static int asptr(PyObject *obj, std::list<T> **lis) {
	return traits_asptr_stdseq<std::list<T> >::asptr(obj, lis);
      }
    };

    template <class T>
    struct traits_from<std::list<T> > {
      static PyObject *from(const std::list<T>& vec) {
	return traits_from_stdseq<std::list<T> >::from(vec);
      }
    };
  }
%}

#define %alaqil_list_methods(Type...) %alaqil_sequence_methods(Type)
#define %alaqil_list_methods_val(Type...) %alaqil_sequence_methods_val(Type);

%include <std/std_list.i>

