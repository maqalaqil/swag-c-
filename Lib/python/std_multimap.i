/*
  Multimaps
*/
%include <std_map.i>

%fragment("StdMultimapTraits","header",fragment="StdMapCommonTraits")
{
  namespace alaqil {
    template <class alaqilPySeq, class K, class T >
    inline void 
    assign(const alaqilPySeq& alaqilpyseq, std::multimap<K,T > *multimap) {
      typedef typename std::multimap<K,T>::value_type value_type;
      typename alaqilPySeq::const_iterator it = alaqilpyseq.begin();
      for (;it != alaqilpyseq.end(); ++it) {
	multimap->insert(value_type(it->first, it->second));
      }
    }

    template <class K, class T>
    struct traits_asptr<std::multimap<K,T> >  {
      typedef std::multimap<K,T> multimap_type;
      static int asptr(PyObject *obj, std::multimap<K,T> **val) {
	int res = alaqil_ERROR;
	if (PyDict_Check(obj)) {
	  alaqilVar_PyObject items = PyObject_CallMethod(obj,(char *)"items",NULL);
%#if PY_VERSION_HEX >= 0x03000000
          /* In Python 3.x the ".items()" method returns a dict_items object */
          items = PySequence_Fast(items, ".items() didn't return a sequence!");
%#endif
	  res = traits_asptr_stdseq<std::multimap<K,T>, std::pair<K, T> >::asptr(items, val);
	} else {
	  multimap_type *p;
	  alaqil_type_info *descriptor = alaqil::type_info<multimap_type>();
	  res = descriptor ? alaqil_ConvertPtr(obj, (void **)&p, descriptor, 0) : alaqil_ERROR;
	  if (alaqil_IsOK(res) && val)  *val = p;
	}
	return res;
      }
    };
      
    template <class K, class T >
    struct traits_from<std::multimap<K,T> >  {
      typedef std::multimap<K,T> multimap_type;
      typedef typename multimap_type::const_iterator const_iterator;
      typedef typename multimap_type::size_type size_type;
            
      static PyObject *from(const multimap_type& multimap) {
	alaqil_type_info *desc = alaqil::type_info<multimap_type>();
	if (desc && desc->clientdata) {
	  return alaqil_InternalNewPointerObj(new multimap_type(multimap), desc, alaqil_POINTER_OWN);
	} else {
	  size_type size = multimap.size();
	  Py_ssize_t pysize = (size <= (size_type) INT_MAX) ? (Py_ssize_t) size : -1;
	  if (pysize < 0) {
	    alaqil_PYTHON_THREAD_BEGIN_BLOCK;
	    PyErr_SetString(PyExc_OverflowError, "multimap size not valid in python");
	    alaqil_PYTHON_THREAD_END_BLOCK;
	    return NULL;
	  }
	  PyObject *obj = PyDict_New();
	  for (const_iterator i= multimap.begin(); i!= multimap.end(); ++i) {
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

%define %alaqil_multimap_methods(Type...) 
  %alaqil_map_common(Type);

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

%include <std/std_multimap.i>

