/*
  Maps
*/

%fragment("StdMapCommonTraits","header",fragment="StdSequenceTraits")
{
  namespace alaqil {
    template <class ValueType>
    struct from_key_oper 
    {
      typedef const ValueType& argument_type;
      typedef  PyObject *result_type;
      result_type operator()(argument_type v) const
      {
	return alaqil::from(v.first);
      }
    };

    template <class ValueType>
    struct from_value_oper 
    {
      typedef const ValueType& argument_type;
      typedef  PyObject *result_type;
      result_type operator()(argument_type v) const
      {
	return alaqil::from(v.second);
      }
    };

    template<class OutIterator, class FromOper, class ValueType = typename OutIterator::value_type>
    struct alaqilPyMapIterator_T : alaqilPyIteratorClosed_T<OutIterator, ValueType, FromOper>
    {
      alaqilPyMapIterator_T(OutIterator curr, OutIterator first, OutIterator last, PyObject *seq)
	: alaqilPyIteratorClosed_T<OutIterator,ValueType,FromOper>(curr, first, last, seq)
      {
      }
    };


    template<class OutIterator,
	     class FromOper = from_key_oper<typename OutIterator::value_type> >
    struct alaqilPyMapKeyIterator_T : alaqilPyMapIterator_T<OutIterator, FromOper>
    {
      alaqilPyMapKeyIterator_T(OutIterator curr, OutIterator first, OutIterator last, PyObject *seq)
	: alaqilPyMapIterator_T<OutIterator, FromOper>(curr, first, last, seq)
      {
      }
    };

    template<typename OutIter>
    inline alaqilPyIterator*
    make_output_key_iterator(const OutIter& current, const OutIter& begin, const OutIter& end, PyObject *seq = 0)
    {
      return new alaqilPyMapKeyIterator_T<OutIter>(current, begin, end, seq);
    }

    template<class OutIterator,
	     class FromOper = from_value_oper<typename OutIterator::value_type> >
    struct alaqilPyMapValueIterator_T : alaqilPyMapIterator_T<OutIterator, FromOper>
    {
      alaqilPyMapValueIterator_T(OutIterator curr, OutIterator first, OutIterator last, PyObject *seq)
	: alaqilPyMapIterator_T<OutIterator, FromOper>(curr, first, last, seq)
      {
      }
    };
    

    template<typename OutIter>
    inline alaqilPyIterator*
    make_output_value_iterator(const OutIter& current, const OutIter& begin, const OutIter& end, PyObject *seq = 0)
    {
      return new alaqilPyMapValueIterator_T<OutIter>(current, begin, end, seq);
    }
  }
}

%fragment("StdMapTraits","header",fragment="StdMapCommonTraits")
{
  namespace alaqil {
    template <class alaqilPySeq, class K, class T, class Compare, class Alloc >
    inline void
    assign(const alaqilPySeq& alaqilpyseq, std::map<K,T,Compare,Alloc > *map) {
      typedef typename std::map<K,T,Compare,Alloc >::value_type value_type;
      typename alaqilPySeq::const_iterator it = alaqilpyseq.begin();
      for (;it != alaqilpyseq.end(); ++it) {
	map->insert(value_type(it->first, it->second));
      }
    }

    template <class K, class T, class Compare, class Alloc>
    struct traits_asptr<std::map<K,T,Compare,Alloc > >  {
      typedef std::map<K,T,Compare,Alloc > map_type;
      static int asptr(PyObject *obj, map_type **val) {
	int res = alaqil_ERROR;
	alaqil_PYTHON_THREAD_BEGIN_BLOCK;
	if (PyDict_Check(obj)) {
	  alaqilVar_PyObject items = PyObject_CallMethod(obj,(char *)"items",NULL);
%#if PY_VERSION_HEX >= 0x03000000
          /* In Python 3.x the ".items()" method returns a dict_items object */
          items = PySequence_Fast(items, ".items() didn't return a sequence!");
%#endif
	  res = traits_asptr_stdseq<map_type, std::pair<K, T> >::asptr(items, val);
	} else {
	  map_type *p;
	  alaqil_type_info *descriptor = alaqil::type_info<map_type>();
	  res = descriptor ? alaqil_ConvertPtr(obj, (void **)&p, descriptor, 0) : alaqil_ERROR;
	  if (alaqil_IsOK(res) && val)  *val = p;
	}
	alaqil_PYTHON_THREAD_END_BLOCK;
	return res;
      }      
    };
      
    template <class K, class T, class Compare, class Alloc >
    struct traits_from<std::map<K,T,Compare,Alloc > >  {
      typedef std::map<K,T,Compare,Alloc > map_type;
      typedef typename map_type::const_iterator const_iterator;
      typedef typename map_type::size_type size_type;

      static PyObject *asdict(const map_type& map) {
	alaqil_PYTHON_THREAD_BEGIN_BLOCK;
	size_type size = map.size();
	Py_ssize_t pysize = (size <= (size_type) INT_MAX) ? (Py_ssize_t) size : -1;
	if (pysize < 0) {
	  PyErr_SetString(PyExc_OverflowError, "map size not valid in python");
	  alaqil_PYTHON_THREAD_END_BLOCK;
	  return NULL;
	}
	PyObject *obj = PyDict_New();
	for (const_iterator i= map.begin(); i!= map.end(); ++i) {
	  alaqil::alaqilVar_PyObject key = alaqil::from(i->first);
	  alaqil::alaqilVar_PyObject val = alaqil::from(i->second);
	  PyDict_SetItem(obj, key, val);
	}
	alaqil_PYTHON_THREAD_END_BLOCK;
	return obj;
      }
                
      static PyObject *from(const map_type& map) {
	alaqil_type_info *desc = alaqil::type_info<map_type>();
	if (desc && desc->clientdata) {
	  return alaqil_InternalNewPointerObj(new map_type(map), desc, alaqil_POINTER_OWN);
	} else {
	  return asdict(map);
	}
      }
    };
  }
}

%define %alaqil_map_common(Map...)
  %alaqil_sequence_iterator(Map);
  %alaqil_container_methods(Map)

#if defined(alaqilPYTHON_BUILTIN)
  %feature("python:slot", "mp_length", functype="lenfunc") __len__;
  %feature("python:slot", "mp_subscript", functype="binaryfunc") __getitem__;
  %feature("python:slot", "tp_iter", functype="getiterfunc") key_iterator;
  %feature("python:slot", "sq_contains", functype="objobjproc") __contains__;

  %extend {
    %newobject iterkeys(PyObject **PYTHON_SELF);
    alaqil::alaqilPyIterator* iterkeys(PyObject **PYTHON_SELF) {
      return alaqil::make_output_key_iterator(self->begin(), self->begin(), self->end(), *PYTHON_SELF);
    }
      
    %newobject itervalues(PyObject **PYTHON_SELF);
    alaqil::alaqilPyIterator* itervalues(PyObject **PYTHON_SELF) {
      return alaqil::make_output_value_iterator(self->begin(), self->begin(), self->end(), *PYTHON_SELF);
    }

    %newobject iteritems(PyObject **PYTHON_SELF);
    alaqil::alaqilPyIterator* iteritems(PyObject **PYTHON_SELF) {
      return alaqil::make_output_iterator(self->begin(), self->begin(), self->end(), *PYTHON_SELF);
    }
  }

#else
  %extend {
    %pythoncode %{def __iter__(self):
    return self.key_iterator()%}
    %pythoncode %{def iterkeys(self):
    return self.key_iterator()%}
    %pythoncode %{def itervalues(self):
    return self.value_iterator()%}
    %pythoncode %{def iteritems(self):
    return self.iterator()%}
  }
#endif

  %extend {
    mapped_type const & __getitem__(const key_type& key) throw (std::out_of_range) {
      Map::const_iterator i = self->find(key);
      if (i != self->end())
	return i->second;
      else
	throw std::out_of_range("key not found");
    }

    void __delitem__(const key_type& key) throw (std::out_of_range) {
      Map::iterator i = self->find(key);
      if (i != self->end())
	self->erase(i);
      else
	throw std::out_of_range("key not found");
    }
    
    bool has_key(const key_type& key) const {
      Map::const_iterator i = self->find(key);
      return i != self->end();
    }
    
    PyObject* keys() {
      Map::size_type size = self->size();
      Py_ssize_t pysize = (size <= (Map::size_type) INT_MAX) ? (Py_ssize_t) size : -1;
      alaqil_PYTHON_THREAD_BEGIN_BLOCK;
      if (pysize < 0) {
	PyErr_SetString(PyExc_OverflowError, "map size not valid in python");
	alaqil_PYTHON_THREAD_END_BLOCK;
	return NULL;
      }
      PyObject* keyList = PyList_New(pysize);
      Map::const_iterator i = self->begin();
      for (Py_ssize_t j = 0; j < pysize; ++i, ++j) {
	PyList_SET_ITEM(keyList, j, alaqil::from(i->first));
      }
      alaqil_PYTHON_THREAD_END_BLOCK;
      return keyList;
    }
    
    PyObject* values() {
      Map::size_type size = self->size();
      Py_ssize_t pysize = (size <= (Map::size_type) INT_MAX) ? (Py_ssize_t) size : -1;
      alaqil_PYTHON_THREAD_BEGIN_BLOCK;
      if (pysize < 0) {
	PyErr_SetString(PyExc_OverflowError, "map size not valid in python");
	alaqil_PYTHON_THREAD_END_BLOCK;
	return NULL;
      }
      PyObject* valList = PyList_New(pysize);
      Map::const_iterator i = self->begin();
      for (Py_ssize_t j = 0; j < pysize; ++i, ++j) {
	PyList_SET_ITEM(valList, j, alaqil::from(i->second));
      }
      alaqil_PYTHON_THREAD_END_BLOCK;
      return valList;
    }
    
    PyObject* items() {
      Map::size_type size = self->size();
      Py_ssize_t pysize = (size <= (Map::size_type) INT_MAX) ? (Py_ssize_t) size : -1;
      alaqil_PYTHON_THREAD_BEGIN_BLOCK;
      if (pysize < 0) {
	PyErr_SetString(PyExc_OverflowError, "map size not valid in python");
	alaqil_PYTHON_THREAD_END_BLOCK;
	return NULL;
      }    
      PyObject* itemList = PyList_New(pysize);
      Map::const_iterator i = self->begin();
      for (Py_ssize_t j = 0; j < pysize; ++i, ++j) {
	PyList_SET_ITEM(itemList, j, alaqil::from(*i));
      }
      alaqil_PYTHON_THREAD_END_BLOCK;
      return itemList;
    }
    
    bool __contains__(const key_type& key) {
      return self->find(key) != self->end();
    }

    %newobject key_iterator(PyObject **PYTHON_SELF);
    alaqil::alaqilPyIterator* key_iterator(PyObject **PYTHON_SELF) {
      return alaqil::make_output_key_iterator(self->begin(), self->begin(), self->end(), *PYTHON_SELF);
    }

    %newobject value_iterator(PyObject **PYTHON_SELF);
    alaqil::alaqilPyIterator* value_iterator(PyObject **PYTHON_SELF) {
      return alaqil::make_output_value_iterator(self->begin(), self->begin(), self->end(), *PYTHON_SELF);
    }
  }

%enddef

%define %alaqil_map_methods(Map...)
  %alaqil_map_common(Map)

#if defined(alaqilPYTHON_BUILTIN)
  %feature("python:slot", "mp_ass_subscript", functype="objobjargproc") __setitem__;
#endif

  %extend {
    // This will be called through the mp_ass_subscript slot to delete an entry.
    void __setitem__(const key_type& key) {
      self->erase(key);
    }

    void __setitem__(const key_type& key, const mapped_type& x) throw (std::out_of_range) {
      (*self)[key] = x;
    }

    PyObject* asdict() {
      return alaqil::traits_from< Map >::asdict(*self);
    }
  }


%enddef


%include <std/std_map.i>
