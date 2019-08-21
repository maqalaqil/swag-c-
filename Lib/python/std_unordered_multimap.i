/*
  Unordered Multimaps
*/
%include <std_unordered_map.i>

%fragment("StdUnorderedMultimapTraits","header",fragment="StdMapCommonTraits",fragment="StdUnorderedMapForwardIteratorTraits")
{
  namespace alaqil {
    template <class alaqilPySeq, class K, class T, class Hash, class Compare, class Alloc>
    inline void 
    assign(const alaqilPySeq& alaqilpyseq, std::unordered_multimap<K,T,Hash,Compare,Alloc> *unordered_multimap) {
      typedef typename std::unordered_multimap<K,T,Hash,Compare,Alloc>::value_type value_type;
      typename alaqilPySeq::const_iterator it = alaqilpyseq.begin();
      for (;it != alaqilpyseq.end(); ++it) {
	unordered_multimap->insert(value_type(it->first, it->second));
      }
    }

    template <class K, class T, class Hash, class Compare, class Alloc>
    struct traits_reserve<std::unordered_multimap<K,T,Hash,Compare,Alloc> >  {
      static void reserve(std::unordered_multimap<K,T,Hash,Compare,Alloc> &seq, typename std::unordered_multimap<K,T,Hash,Compare,Alloc>::size_type n) {
        seq.reserve(n);
      }
    };

    template <class K, class T, class Hash, class Compare, class Alloc>
    struct traits_asptr<std::unordered_multimap<K,T,Hash,Compare,Alloc> >  {
      typedef std::unordered_multimap<K,T,Hash,Compare,Alloc> unordered_multimap_type;
      static int asptr(PyObject *obj, std::unordered_multimap<K,T,Hash,Compare,Alloc> **val) {
	int res = alaqil_ERROR;
	if (PyDict_Check(obj)) {
	  alaqilVar_PyObject items = PyObject_CallMethod(obj,(char *)"items",NULL);
%#if PY_VERSION_HEX >= 0x03000000
          /* In Python 3.x the ".items()" method returns a dict_items object */
          items = PySequence_Fast(items, ".items() didn't return a sequence!");
%#endif
	  res = traits_asptr_stdseq<std::unordered_multimap<K,T,Hash,Compare,Alloc>, std::pair<K, T> >::asptr(items, val);
	} else {
	  unordered_multimap_type *p;
	  alaqil_type_info *descriptor = alaqil::type_info<unordered_multimap_type>();
	  res = descriptor ? alaqil_ConvertPtr(obj, (void **)&p, descriptor, 0) : alaqil_ERROR;
	  if (alaqil_IsOK(res) && val)  *val = p;
	}
	return res;
      }
    };
      
    template <class K, class T, class Hash, class Compare, class Alloc>
    struct traits_from<std::unordered_multimap<K,T,Hash,Compare,Alloc> >  {
      typedef std::unordered_multimap<K,T,Hash,Compare,Alloc> unordered_multimap_type;
      typedef typename unordered_multimap_type::const_iterator const_iterator;
      typedef typename unordered_multimap_type::size_type size_type;
            
      static PyObject *from(const unordered_multimap_type& unordered_multimap) {
	alaqil_type_info *desc = alaqil::type_info<unordered_multimap_type>();
	if (desc && desc->clientdata) {
	  return alaqil_InternalNewPointerObj(new unordered_multimap_type(unordered_multimap), desc, alaqil_POINTER_OWN);
	} else {
	  size_type size = unordered_multimap.size();
	  Py_ssize_t pysize = (size <= (size_type) INT_MAX) ? (Py_ssize_t) size : -1;
	  if (pysize < 0) {
	    alaqil_PYTHON_THREAD_BEGIN_BLOCK;
	    PyErr_SetString(PyExc_OverflowError, "unordered_multimap size not valid in python");
	    alaqil_PYTHON_THREAD_END_BLOCK;
	    return NULL;
	  }
	  PyObject *obj = PyDict_New();
	  for (const_iterator i= unordered_multimap.begin(); i!= unordered_multimap.end(); ++i) {
	    alaqil::alaqilVar_PyObject key = alaqil::from(i->first);
	    alaqil::alaqilVar_PyObject val = alaqil::from(i->second);
	    PyDict_SetItem(obj, key, val);
	  }
	  return obj;
	}
      }
    };
  }
}

%define %alaqil_unordered_multimap_methods(Type...) 
  %alaqil_unordered_map_common(Type);

#if defined(alaqilPYTHON_BUILTIN)
  %feature("python:slot", "mp_ass_subscript", functype="objobjargproc") __setitem__;
#endif

  %extend {
    // This will be called through the mp_ass_subscript slot to delete an entry.
    void __setitem__(const key_type& key) {
      self->erase(key);
    }

    void __setitem__(const key_type& key, const mapped_type& x) throw (std::out_of_range) {
      self->insert(Type::value_type(key,x));
    }
  }
%enddef

%include <std/std_unordered_multimap.i>

