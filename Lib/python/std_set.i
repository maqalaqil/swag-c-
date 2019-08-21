/*
  Sets
*/

%fragment("StdSetTraits","header",fragment="StdSequenceTraits")
%{
  namespace alaqil {
    template <class alaqilPySeq, class T> 
    inline void 
    assign(const alaqilPySeq& alaqilpyseq, std::set<T>* seq) {
      // seq->insert(alaqilpyseq.begin(), alaqilpyseq.end()); // not used as not always implemented
      typedef typename alaqilPySeq::value_type value_type;
      typename alaqilPySeq::const_iterator it = alaqilpyseq.begin();
      for (;it != alaqilpyseq.end(); ++it) {
	seq->insert(seq->end(),(value_type)(*it));
      }
    }

    template <class T>
    struct traits_asptr<std::set<T> >  {
      static int asptr(PyObject *obj, std::set<T> **s) {
	return traits_asptr_stdseq<std::set<T> >::asptr(obj, s);
      }
    };

    template <class T>
    struct traits_from<std::set<T> > {
      static PyObject *from(const std::set<T>& vec) {
	return traits_from_stdseq<std::set<T> >::from(vec);
      }
    };
  }
%}

%define %alaqil_set_methods(set...)
  %alaqil_sequence_iterator(set);
  %alaqil_container_methods(set);

#if defined(alaqilPYTHON_BUILTIN)
  %feature("python:slot", "mp_subscript", functype="binaryfunc") __getitem__;
  %feature("python:slot", "sq_contains", functype="objobjproc") __contains__;
#endif

  %extend {
     void append(value_type x) {
       self->insert(x);
     }
  
     bool __contains__(value_type x) {
       return self->find(x) != self->end();
     }

     value_type __getitem__(difference_type i) const throw (std::out_of_range) {
       return *(alaqil::cgetpos(self, i));
     }

     void add(value_type x) {
       self->insert(x);
     }

     void discard(value_type x) {
       self->erase(x);
     }
  }
%enddef

%include <std/std_set.i>
