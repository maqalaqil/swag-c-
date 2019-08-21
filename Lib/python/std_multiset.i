/*
  Multisets
*/

%include <std_set.i>

%fragment("StdMultisetTraits","header",fragment="StdSequenceTraits")
%{
  namespace alaqil {
    template <class alaqilPySeq, class T> 
    inline void
    assign(const alaqilPySeq& alaqilpyseq, std::multiset<T>* seq) {
      // seq->insert(alaqilpyseq.begin(), alaqilpyseq.end()); // not used as not always implemented
      typedef typename alaqilPySeq::value_type value_type;
      typename alaqilPySeq::const_iterator it = alaqilpyseq.begin();
      for (;it != alaqilpyseq.end(); ++it) {
	seq->insert(seq->end(),(value_type)(*it));
      }
    }

    template <class T>
    struct traits_asptr<std::multiset<T> >  {
      static int asptr(PyObject *obj, std::multiset<T> **m) {
	return traits_asptr_stdseq<std::multiset<T> >::asptr(obj, m);
      }
    };

    template <class T>
    struct traits_from<std::multiset<T> > {
      static PyObject *from(const std::multiset<T>& vec) {
	return traits_from_stdseq<std::multiset<T> >::from(vec);
      }
    };
  }
%}

#define %alaqil_multiset_methods(Set...) %alaqil_set_methods(Set)



%include <std/std_multiset.i>
