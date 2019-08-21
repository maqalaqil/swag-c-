/*
  Unordered Multisets
*/

%include <std_unordered_set.i>

%fragment("StdUnorderedMultisetTraits","header",fragment="StdSequenceTraits")
%{
  namespace alaqil {
    template <class alaqilPySeq, class Key, class Hash, class Compare, class Alloc>
    inline void
    assign(const alaqilPySeq& alaqilpyseq, std::unordered_multiset<Key,Hash,Compare,Alloc>* seq) {
      // seq->insert(alaqilpyseq.begin(), alaqilpyseq.end()); // not used as not always implemented
      typedef typename alaqilPySeq::value_type value_type;
      typename alaqilPySeq::const_iterator it = alaqilpyseq.begin();
      for (;it != alaqilpyseq.end(); ++it) {
	seq->insert(seq->end(),(value_type)(*it));
      }
    }

    template <class Key, class Hash, class Compare, class Alloc>
    struct traits_reserve<std::unordered_multiset<Key,Hash,Compare,Alloc> >  {
      static void reserve(std::unordered_multiset<Key,Hash,Compare,Alloc> &seq, typename std::unordered_multiset<Key,Hash,Compare,Alloc>::size_type n) {
        seq.reserve(n);
      }
    };

    template <class Key, class Hash, class Compare, class Alloc>
    struct traits_asptr<std::unordered_multiset<Key,Hash,Compare,Alloc> >  {
      static int asptr(PyObject *obj, std::unordered_multiset<Key,Hash,Compare,Alloc> **m) {
	return traits_asptr_stdseq<std::unordered_multiset<Key,Hash,Compare,Alloc> >::asptr(obj, m);
      }
    };

    template <class Key, class Hash, class Compare, class Alloc>
    struct traits_from<std::unordered_multiset<Key,Hash,Compare,Alloc> > {
      static PyObject *from(const std::unordered_multiset<Key,Hash,Compare,Alloc>& vec) {
	return traits_from_stdseq<std::unordered_multiset<Key,Hash,Compare,Alloc> >::from(vec);
      }
    };
  }
%}

#define %alaqil_unordered_multiset_methods(Set...) %alaqil_unordered_set_methods(Set)



%include <std/std_unordered_multiset.i>
