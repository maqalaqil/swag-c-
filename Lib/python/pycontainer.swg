/* -----------------------------------------------------------------------------
 * pycontainer.swg
 *
 * Python sequence <-> C++ container wrapper
 *
 * This wrapper, and its iterator, allows a general use (and reuse) of
 * the mapping between C++ and Python, thanks to the C++ templates.
 *
 * Of course, it needs the C++ compiler to support templates, but
 * since we will use this wrapper with the STL containers, that should
 * be the case.
 * ----------------------------------------------------------------------------- */

%{
#include <iostream>

#if PY_VERSION_HEX >= 0x03020000
# define alaqilPY_SLICE_ARG(obj) ((PyObject*) (obj))
#else
# define alaqilPY_SLICE_ARG(obj) ((PySliceObject*) (obj))
#endif
%}


#if !defined(alaqil_NO_EXPORT_ITERATOR_METHODS)
# if !defined(alaqil_EXPORT_ITERATOR_METHODS)
#  define alaqil_EXPORT_ITERATOR_METHODS alaqil_EXPORT_ITERATOR_METHODS
# endif
#endif

%include <pyiterators.swg>

/**** The PySequence C++ Wrap ***/

%fragment("<stdexcept>");

%include <std_except.i>

%fragment("container_owner_attribute_init", "init") {
  // thread safe initialization
  alaqil::container_owner_attribute();
}

%fragment("reference_container_owner", "header", fragment="container_owner_attribute_init") {
namespace alaqil {
  static PyObject* container_owner_attribute() {
    static PyObject* attr = alaqil_Python_str_FromChar("__alaqil_container");
    return attr;
  }

  template <typename T>
  struct container_owner {
    // By default, do not add the back-reference (for value types)
    // Specialization below will check the reference for pointer types.
    static bool back_reference(PyObject* child, PyObject* owner) {
      return false;
    }
  };

  template <>
  struct container_owner<alaqil::pointer_category> {  
    /*
     * Call to add a back-reference to the owning object when returning a 
     * reference from a container.  Will only set the reference if child
     * is a alaqil wrapper object that does not own the pointer.
     *
     * returns whether the reference was set or not
     */
    static bool back_reference(PyObject* child, PyObject* owner) {
      alaqilPyObject* alaqilThis = alaqil_Python_GetalaqilThis(child);
      if (alaqilThis && (alaqilThis->own & alaqil_POINTER_OWN) != alaqil_POINTER_OWN) {
        PyObject_SetAttr(child, container_owner_attribute(), owner);
        return true;
      }
      return false;
    }
  };
}
}

%fragment(alaqil_Traits_frag(alaqil::alaqilPtr_PyObject),"header",fragment="StdTraits") {
namespace alaqil {
  template <>  struct traits<alaqilPtr_PyObject > {
    typedef value_category category;
    static const char* type_name() { return  "alaqilPtr_PyObject"; }
  };
  
  template <>  struct traits_from<alaqilPtr_PyObject> {
    typedef alaqilPtr_PyObject value_type;
    static PyObject *from(const value_type& val) {
      PyObject *obj = static_cast<PyObject *>(val);
      Py_XINCREF(obj);
      return obj;
    }
  };
  
  template <> 
  struct traits_check<alaqilPtr_PyObject, value_category> {
    static bool check(alaqilPtr_PyObject) {
      return true;
    }
  };
  
  template <>  struct traits_asval<alaqilPtr_PyObject > {   
    typedef alaqilPtr_PyObject value_type;
    static int asval(PyObject *obj, value_type *val) {
      if (val) *val = obj;
      return alaqil_OK;
    }
  };
}
}

%fragment(alaqil_Traits_frag(alaqil::alaqilVar_PyObject),"header",fragment="StdTraits") {
namespace alaqil {
  template <>  struct traits<alaqilVar_PyObject > {
    typedef value_category category;
    static const char* type_name() { return  "alaqilVar_PyObject"; }
  };
  
  template <>  struct traits_from<alaqilVar_PyObject> {
    typedef alaqilVar_PyObject value_type;
    static PyObject *from(const value_type& val) {
      PyObject *obj = static_cast<PyObject *>(val);
      Py_XINCREF(obj);
      return obj;
    }
  };
  
  template <> 
  struct traits_check<alaqilVar_PyObject, value_category> {
    static bool check(alaqilVar_PyObject) {
      return true;
    }
  };
  
  template <>  struct traits_asval<alaqilVar_PyObject > {   
    typedef alaqilVar_PyObject value_type;
    static int asval(PyObject *obj, value_type *val) {
      if (val) *val = obj;
      return alaqil_OK;
    }
  };
} 
}

%fragment("alaqilPySequence_Base","header",fragment="<stddef.h>",fragment="StdTraits")
{
%#include <functional>

namespace std {
  template <>
  struct less <PyObject *>
  {
    bool
    operator()(PyObject * v, PyObject *w) const
    { 
      bool res;
      alaqil_PYTHON_THREAD_BEGIN_BLOCK;
      res = PyObject_RichCompareBool(v, w, Py_LT) ? true : false;
      /* This may fall into a case of inconsistent
               eg. ObjA > ObjX > ObjB
               but ObjA < ObjB
      */
      if( PyErr_Occurred() && PyErr_ExceptionMatches(PyExc_TypeError) )
      {
        /* Objects can't be compared, this mostly occurred in Python 3.0 */
        /* Compare their ptr directly for a workaround */
        res = (v < w);
        PyErr_Clear();
      }
      alaqil_PYTHON_THREAD_END_BLOCK;
      return res;
    }
  };

  template <>
  struct less <alaqil::alaqilPtr_PyObject>
  {
    bool
    operator()(const alaqil::alaqilPtr_PyObject& v, const alaqil::alaqilPtr_PyObject& w) const
    {
      return std::less<PyObject *>()(v, w);
    }
  };

  template <>
  struct less <alaqil::alaqilVar_PyObject>
  {
    bool
    operator()(const alaqil::alaqilVar_PyObject& v, const alaqil::alaqilVar_PyObject& w) const
    {
      return std::less<PyObject *>()(v, w);
    }
  };

}

namespace alaqil {
  template <> struct traits<PyObject *> {
    typedef value_category category;
    static const char* type_name() { return "PyObject *"; }
  };  

  template <>  struct traits_asval<PyObject * > {   
    typedef PyObject * value_type;
    static int asval(PyObject *obj, value_type *val) {
      if (val) *val = obj;
      return alaqil_OK;
    }
  };

  template <> 
  struct traits_check<PyObject *, value_category> {
    static bool check(PyObject *) {
      return true;
    }
  };

  template <>  struct traits_from<PyObject *> {
    typedef PyObject * value_type;
    static PyObject *from(const value_type& val) {
      Py_XINCREF(val);
      return val;
    }
  };
  
}

namespace alaqil {
  template <class Difference>
  inline size_t
  check_index(Difference i, size_t size, bool insert = false) {
    if ( i < 0 ) {
      if ((size_t) (-i) <= size)
	return (size_t) (i + size);
    } else if ( (size_t) i < size ) {
      return (size_t) i;
    } else if (insert && ((size_t) i == size)) {
      return size;
    }
    throw std::out_of_range("index out of range");
  }

  template <class Difference>
  void
  slice_adjust(Difference i, Difference j, Py_ssize_t step, size_t size, Difference &ii, Difference &jj, bool insert = false) {
    if (step == 0) {
      throw std::invalid_argument("slice step cannot be zero");
    } else if (step > 0) {
      // Required range: 0 <= i < size, 0 <= j < size, i <= j
      if (i < 0) {
        ii = 0;
      } else if (i < (Difference)size) {
        ii = i;
      } else if (insert && (i >= (Difference)size)) {
        ii = (Difference)size;
      }
      if (j < 0) {
        jj = 0;
      } else {
        jj = (j < (Difference)size) ? j : (Difference)size;
      }
      if (jj < ii)
        jj = ii;
    } else {
      // Required range: -1 <= i < size-1, -1 <= j < size-1, i >= j
      if (i < -1) {
        ii = -1;
      } else if (i < (Difference) size) {
        ii = i;
      } else if (i >= (Difference)(size-1)) {
        ii = (Difference)(size-1);
      }
      if (j < -1) {
        jj = -1;
      } else {
        jj = (j < (Difference)size ) ? j : (Difference)(size-1);
      }
      if (ii < jj)
        ii = jj;
    }
  }

  template <class Sequence, class Difference>
  inline typename Sequence::iterator
  getpos(Sequence* self, Difference i)  {
    typename Sequence::iterator pos = self->begin();
    std::advance(pos, check_index(i,self->size()));
    return pos;
  }

  template <class Sequence, class Difference>
  inline typename Sequence::const_iterator
  cgetpos(const Sequence* self, Difference i)  {
    typename Sequence::const_iterator pos = self->begin();
    std::advance(pos, check_index(i,self->size()));
    return pos;
  }

  template <class Sequence>
  inline void
  erase(Sequence* seq, const typename Sequence::iterator& position) {
    seq->erase(position);
  }

  template <class Sequence>
  struct traits_reserve {
    static void reserve(Sequence & /*seq*/, typename Sequence::size_type /*n*/) {
      // This should be specialized for types that support reserve
    }
  };

  template <class Sequence, class Difference>
  inline Sequence*
  getslice(const Sequence* self, Difference i, Difference j, Py_ssize_t step) {
    typename Sequence::size_type size = self->size();
    Difference ii = 0;
    Difference jj = 0;
    alaqil::slice_adjust(i, j, step, size, ii, jj);

    if (step > 0) {
      typename Sequence::const_iterator sb = self->begin();
      typename Sequence::const_iterator se = self->begin();
      std::advance(sb,ii);
      std::advance(se,jj);
      if (step == 1) {
        return new Sequence(sb, se);
      } else {
        Sequence *sequence = new Sequence();
        alaqil::traits_reserve<Sequence>::reserve(*sequence, (jj - ii + step - 1) / step);
        typename Sequence::const_iterator it = sb;
        while (it!=se) {
          sequence->push_back(*it);
          for (Py_ssize_t c=0; c<step && it!=se; ++c)
            it++;
        }
        return sequence;
      } 
    } else {
      Sequence *sequence = new Sequence();
      alaqil::traits_reserve<Sequence>::reserve(*sequence, (ii - jj - step - 1) / -step);
      typename Sequence::const_reverse_iterator sb = self->rbegin();
      typename Sequence::const_reverse_iterator se = self->rbegin();
      std::advance(sb,size-ii-1);
      std::advance(se,size-jj-1);
      typename Sequence::const_reverse_iterator it = sb;
      while (it!=se) {
        sequence->push_back(*it);
        for (Py_ssize_t c=0; c<-step && it!=se; ++c)
          it++;
      }
      return sequence;
    }
  }

  template <class Sequence, class Difference, class InputSeq>
  inline void
  setslice(Sequence* self, Difference i, Difference j, Py_ssize_t step, const InputSeq& is = InputSeq()) {
    typename Sequence::size_type size = self->size();
    Difference ii = 0;
    Difference jj = 0;
    alaqil::slice_adjust(i, j, step, size, ii, jj, true);
    if (step > 0) {
      if (step == 1) {
        size_t ssize = jj - ii;
        if (ssize <= is.size()) {
          // expanding/staying the same size
          alaqil::traits_reserve<Sequence>::reserve(*self, self->size() - ssize + is.size());
          typename Sequence::iterator sb = self->begin();
          typename InputSeq::const_iterator isit = is.begin();
          std::advance(sb,ii);
          std::advance(isit, jj - ii);
          self->insert(std::copy(is.begin(), isit, sb), isit, is.end());
        } else {
          // shrinking
          typename Sequence::iterator sb = self->begin();
          typename Sequence::iterator se = self->begin();
          std::advance(sb,ii);
          std::advance(se,jj);
          self->erase(sb,se);
          sb = self->begin();
          std::advance(sb,ii);
          self->insert(sb, is.begin(), is.end());
        }
      } else {
        size_t replacecount = (jj - ii + step - 1) / step;
        if (is.size() != replacecount) {
          char msg[1024];
          sprintf(msg, "attempt to assign sequence of size %lu to extended slice of size %lu", (unsigned long)is.size(), (unsigned long)replacecount);
          throw std::invalid_argument(msg);
        }
        typename Sequence::const_iterator isit = is.begin();
        typename Sequence::iterator it = self->begin();
        std::advance(it,ii);
        for (size_t rc=0; rc<replacecount && it != self->end(); ++rc) {
          *it++ = *isit++;
          for (Py_ssize_t c=0; c<(step-1) && it != self->end(); ++c)
            it++;
        }
      }
    } else {
      size_t replacecount = (ii - jj - step - 1) / -step;
      if (is.size() != replacecount) {
        char msg[1024];
        sprintf(msg, "attempt to assign sequence of size %lu to extended slice of size %lu", (unsigned long)is.size(), (unsigned long)replacecount);
        throw std::invalid_argument(msg);
      }
      typename Sequence::const_iterator isit = is.begin();
      typename Sequence::reverse_iterator it = self->rbegin();
      std::advance(it,size-ii-1);
      for (size_t rc=0; rc<replacecount && it != self->rend(); ++rc) {
        *it++ = *isit++;
        for (Py_ssize_t c=0; c<(-step-1) && it != self->rend(); ++c)
          it++;
      }
    }
  }

  template <class Sequence, class Difference>
  inline void
  delslice(Sequence* self, Difference i, Difference j, Py_ssize_t step) {
    typename Sequence::size_type size = self->size();
    Difference ii = 0;
    Difference jj = 0;
    alaqil::slice_adjust(i, j, step, size, ii, jj, true);
    if (step > 0) {
      typename Sequence::iterator sb = self->begin();
      std::advance(sb,ii);
      if (step == 1) {
        typename Sequence::iterator se = self->begin();
        std::advance(se,jj);
        self->erase(sb,se);
      } else {
        typename Sequence::iterator it = sb;
        size_t delcount = (jj - ii + step - 1) / step;
        while (delcount) {
          it = self->erase(it);
          for (Py_ssize_t c=0; c<(step-1) && it != self->end(); ++c)
            it++;
          delcount--;
        }
      }
    } else {
      typename Sequence::reverse_iterator sb = self->rbegin();
      std::advance(sb,size-ii-1);
      typename Sequence::reverse_iterator it = sb;
      size_t delcount = (ii - jj - step - 1) / -step;
      while (delcount) {
        it = typename Sequence::reverse_iterator(self->erase((++it).base()));
        for (Py_ssize_t c=0; c<(-step-1) && it != self->rend(); ++c)
          it++;
        delcount--;
      }
    }
  }
}
}

%fragment("alaqilPySequence_Cont","header",
	  fragment="StdTraits",
	  fragment="alaqilPySequence_Base",
	  fragment="alaqilPyIterator_T")
{
namespace alaqil
{
  template <class T>
  struct alaqilPySequence_Ref
  {
    alaqilPySequence_Ref(PyObject* seq, Py_ssize_t index)
      : _seq(seq), _index(index)
    {
    }
    
    operator T () const
    {
      alaqil::alaqilVar_PyObject item = PySequence_GetItem(_seq, _index);
      try {
	return alaqil::as<T>(item);
      } catch (const std::invalid_argument& e) {
	char msg[1024];
	sprintf(msg, "in sequence element %d ", (int)_index);
	if (!PyErr_Occurred()) {
	  ::%type_error(alaqil::type_name<T>());
	}
	alaqil_Python_AddErrorMsg(msg);
	alaqil_Python_AddErrorMsg(e.what());
	throw;
      }
    }

    alaqilPySequence_Ref& operator=(const T& v)
    {
      PySequence_SetItem(_seq, _index, alaqil::from<T>(v));
      return *this;
    }

  private:
    PyObject* _seq;
    Py_ssize_t _index;
  };

  template <class T>
  struct alaqilPySequence_ArrowProxy
  {
    alaqilPySequence_ArrowProxy(const T& x): m_value(x) {}
    const T* operator->() const { return &m_value; }
    operator const T*() const { return &m_value; }
    T m_value;
  };

  template <class T, class Reference >
  struct alaqilPySequence_InputIterator
  {
    typedef alaqilPySequence_InputIterator<T, Reference > self;

    typedef std::random_access_iterator_tag iterator_category;
    typedef Reference reference;
    typedef T value_type;
    typedef T* pointer;
    typedef Py_ssize_t difference_type;

    alaqilPySequence_InputIterator()
    {
    }

    alaqilPySequence_InputIterator(PyObject* seq, Py_ssize_t index)
      : _seq(seq), _index(index)
    {
    }

    reference operator*() const
    {
      return reference(_seq, _index);
    }

    alaqilPySequence_ArrowProxy<T>
    operator->() const {
      return alaqilPySequence_ArrowProxy<T>(operator*());
    }

    bool operator==(const self& ri) const
    {
      return (_index == ri._index) && (_seq == ri._seq);
    }

    bool operator!=(const self& ri) const
    {
      return !(operator==(ri));
    }

    self& operator ++ ()
    {
      ++_index;
      return *this;
    }

    self& operator -- ()
    {
      --_index;
      return *this;
    }

    self& operator += (difference_type n)
    {
      _index += n;
      return *this;
    }

    self operator +(difference_type n) const
    {
      return self(_seq, _index + n);
    }

    self& operator -= (difference_type n)
    {
      _index -= n;
      return *this;
    }

    self operator -(difference_type n) const
    {
      return self(_seq, _index - n);
    }

    difference_type operator - (const self& ri) const
    {
      return _index - ri._index;
    }

    bool operator < (const self& ri) const
    {
      return _index < ri._index;
    }

    reference
    operator[](difference_type n) const
    {
      return reference(_seq, _index + n);
    }

  private:
    PyObject* _seq;
    difference_type _index;
  };

  // STL container wrapper around a Python sequence
  template <class T>
  struct alaqilPySequence_Cont
  {
    typedef alaqilPySequence_Ref<T> reference;
    typedef const alaqilPySequence_Ref<T> const_reference;
    typedef T value_type;
    typedef T* pointer;
    typedef Py_ssize_t difference_type;
    typedef size_t size_type;
    typedef const pointer const_pointer;
    typedef alaqilPySequence_InputIterator<T, reference> iterator;
    typedef alaqilPySequence_InputIterator<T, const_reference> const_iterator;

    alaqilPySequence_Cont(PyObject* seq) : _seq(0)
    {
      if (!PySequence_Check(seq)) {
	throw std::invalid_argument("a sequence is expected");
      }
      _seq = seq;
      Py_INCREF(_seq);
    }

    ~alaqilPySequence_Cont()
    {
      Py_XDECREF(_seq);
    }

    size_type size() const
    {
      return static_cast<size_type>(PySequence_Size(_seq));
    }

    bool empty() const
    {
      return size() == 0;
    }

    iterator begin()
    {
      return iterator(_seq, 0);
    }

    const_iterator begin() const
    {
      return const_iterator(_seq, 0);
    }

    iterator end()
    {
      return iterator(_seq, size());
    }

    const_iterator end() const
    {
      return const_iterator(_seq, size());
    }

    reference operator[](difference_type n)
    {
      return reference(_seq, n);
    }

    const_reference operator[](difference_type n)  const
    {
      return const_reference(_seq, n);
    }

    bool check(bool set_err = true) const
    {
      Py_ssize_t s = size();
      for (Py_ssize_t i = 0; i < s; ++i) {
	alaqil::alaqilVar_PyObject item = PySequence_GetItem(_seq, i);
	if (!alaqil::check<value_type>(item)) {
	  if (set_err) {
	    char msg[1024];
	    sprintf(msg, "in sequence element %d", (int)i);
	    alaqil_Error(alaqil_RuntimeError, msg);
	  }
	  return false;
	}
      }
      return true;
    }

  private:
    PyObject* _seq;
  };

}
}

%define %alaqil_sequence_iterator(Sequence...)
  %alaqil_sequence_iterator_with_making_function(alaqil::make_output_iterator,Sequence...)
%enddef

%define %alaqil_sequence_forward_iterator(Sequence...)
  %alaqil_sequence_iterator_with_making_function(alaqil::make_output_forward_iterator,Sequence...)
%enddef

%define %alaqil_sequence_iterator_with_making_function(Make_output_iterator,Sequence...)
#if defined(alaqil_EXPORT_ITERATOR_METHODS)
  class iterator;
  class reverse_iterator;
  class const_iterator;
  class const_reverse_iterator;

  %typemap(out,noblock=1,fragment="alaqilPySequence_Cont")
    iterator, reverse_iterator, const_iterator, const_reverse_iterator {
    $result = alaqil_NewPointerObj(Make_output_iterator(%static_cast($1,const $type &)),
				 alaqil::alaqilPyIterator::descriptor(),alaqil_POINTER_OWN);
  }
  %typemap(out,noblock=1,fragment="alaqilPySequence_Cont")
    std::pair<iterator, iterator>, std::pair<const_iterator, const_iterator> {
    $result = PyTuple_New(2);
    PyTuple_SetItem($result,0,alaqil_NewPointerObj(Make_output_iterator(%static_cast($1,const $type &).first),
						 alaqil::alaqilPyIterator::descriptor(),alaqil_POINTER_OWN));
    PyTuple_SetItem($result,1,alaqil_NewPointerObj(Make_output_iterator(%static_cast($1,const $type &).second),
						 alaqil::alaqilPyIterator::descriptor(),alaqil_POINTER_OWN));    
  }

  %fragment("alaqilPyPairBoolOutputIterator","header",fragment=alaqil_From_frag(bool),fragment="alaqilPySequence_Cont") {}

  %typemap(out,noblock=1,fragment="alaqilPyPairBoolOutputIterator")
    std::pair<iterator, bool>, std::pair<const_iterator, bool> {
    $result = PyTuple_New(2);
    PyTuple_SetItem($result,0,alaqil_NewPointerObj(Make_output_iterator(%static_cast($1,const $type &).first),
					       alaqil::alaqilPyIterator::descriptor(),alaqil_POINTER_OWN));    
    PyTuple_SetItem($result,1,alaqil_From(bool)(%static_cast($1,const $type &).second));
  }

  %typemap(in,noblock=1,fragment="alaqilPySequence_Cont")
    iterator(alaqil::alaqilPyIterator *iter = 0, int res),
    reverse_iterator(alaqil::alaqilPyIterator *iter = 0, int res),
    const_iterator(alaqil::alaqilPyIterator *iter = 0, int res),
    const_reverse_iterator(alaqil::alaqilPyIterator *iter = 0, int res) {
    res = alaqil_ConvertPtr($input, %as_voidptrptr(&iter), alaqil::alaqilPyIterator::descriptor(), 0);
    if (!alaqil_IsOK(res) || !iter) {
      %argument_fail(alaqil_TypeError, "$type", $symname, $argnum);
    } else {
      alaqil::alaqilPyIterator_T<$type > *iter_t = dynamic_cast<alaqil::alaqilPyIterator_T<$type > *>(iter);
      if (iter_t) {
	$1 = iter_t->get_current();
      } else {
	%argument_fail(alaqil_TypeError, "$type", $symname, $argnum);
      }
    }
  }

  %typecheck(%checkcode(ITERATOR),noblock=1,fragment="alaqilPySequence_Cont")
    iterator, reverse_iterator, const_iterator, const_reverse_iterator {
    alaqil::alaqilPyIterator *iter = 0;
    int res = alaqil_ConvertPtr($input, %as_voidptrptr(&iter), alaqil::alaqilPyIterator::descriptor(), 0);
    $1 = (alaqil_IsOK(res) && iter && (dynamic_cast<alaqil::alaqilPyIterator_T<$type > *>(iter) != 0));
  }

  %fragment("alaqilPySequence_Cont");

  %newobject iterator(PyObject **PYTHON_SELF);
  %extend  {
    alaqil::alaqilPyIterator* iterator(PyObject **PYTHON_SELF) {
      return Make_output_iterator(self->begin(), self->begin(), self->end(), *PYTHON_SELF);
    }

#if defined(alaqilPYTHON_BUILTIN)
  %feature("python:slot", "tp_iter", functype="getiterfunc") iterator;
#else
  %pythoncode %{def __iter__(self):
    return self.iterator()%}
#endif
  }

#endif //alaqil_EXPORT_ITERATOR_METHODS
%enddef


/**** The python container methods  ****/

%define %alaqil_container_methods(Container...)

/* deprecated in Python 2 */
#if 1
  %newobject __getslice__;
#endif
  %newobject __getitem__(PySliceObject *slice);

#if defined(alaqilPYTHON_BUILTIN)
  %feature("python:slot", "nb_nonzero", functype="inquiry") __nonzero__;
  %feature("python:slot", "sq_length", functype="lenfunc") __len__;
#endif // alaqilPYTHON_BUILTIN

  %extend {
    bool __nonzero__() const {
      return !(self->empty());
    }

    /* Alias for Python 3 compatibility */
    bool __bool__() const {
      return !(self->empty());
    }

    size_type __len__() const {
      return self->size();
    }

    // Although __getitem__, front, back actually use a const value_type& return type, the typemaps below
    // use non-const so that they can be easily overridden by users if necessary.
    %typemap(ret, fragment="reference_container_owner", noblock=1) value_type& __getitem__, value_type& front, value_type& back {
      (void)alaqil::container_owner<alaqil::traits<$*1_ltype>::category>::back_reference($result, $self);
    }
  }
%enddef



%define %alaqil_sequence_methods_common(Sequence...)
  %alaqil_sequence_iterator(%arg(Sequence))
  %alaqil_container_methods(%arg(Sequence))

  %fragment("alaqilPySequence_Base");

#if defined(alaqilPYTHON_BUILTIN)
  //%feature("python:slot", "sq_item", functype="ssizeargfunc") __getitem__;
  //%feature("python:slot", "sq_slice", functype="ssizessizeargfunc") __getslice__;
  //%feature("python:slot", "sq_ass_item", functype="ssizeobjargproc") __setitem__;
  //%feature("python:slot", "sq_ass_slice", functype="ssizessizeobjargproc") __setslice__;
  %feature("python:slot", "mp_subscript", functype="binaryfunc") __getitem__;
  %feature("python:slot", "mp_ass_subscript", functype="objobjargproc") __setitem__;
#endif // alaqilPYTHON_BUILTIN

  %extend {
    /* typemap for slice object support */
    %typemap(in) PySliceObject* {
      if (!PySlice_Check($input)) {
        %argument_fail(alaqil_TypeError, "$type", $symname, $argnum);
      }
      $1 = (PySliceObject *) $input;
    }
    %typemap(typecheck,precedence=alaqil_TYPECHECK_POINTER) PySliceObject* {
      $1 = PySlice_Check($input);
    }

/* deprecated in Python 2 */
#if 1
    Sequence* __getslice__(difference_type i, difference_type j) throw (std::out_of_range, std::invalid_argument) {
      return alaqil::getslice(self, i, j, 1);
    }

    void __setslice__(difference_type i, difference_type j) throw (std::out_of_range, std::invalid_argument) {
      alaqil::setslice(self, i, j, 1, Sequence());
    }

    void __setslice__(difference_type i, difference_type j, const Sequence& v) throw (std::out_of_range, std::invalid_argument) {
      alaqil::setslice(self, i, j, 1, v);
    }

    void __delslice__(difference_type i, difference_type j) throw (std::out_of_range, std::invalid_argument) {
      alaqil::delslice(self, i, j, 1);
    }
#endif

    void __delitem__(difference_type i) throw (std::out_of_range, std::invalid_argument) {
      alaqil::erase(self, alaqil::getpos(self, i));
    }

    /* Overloaded methods for Python 3 compatibility 
     * (Also useful in Python 2.x)
     */
    Sequence* __getitem__(PySliceObject *slice) throw (std::out_of_range, std::invalid_argument) {
      Py_ssize_t i, j, step;
      if( !PySlice_Check(slice) ) {
        alaqil_Error(alaqil_TypeError, "Slice object expected.");
        return NULL;
      }
      PySlice_GetIndices(alaqilPY_SLICE_ARG(slice), (Py_ssize_t)self->size(), &i, &j, &step);
      Sequence::difference_type id = i;
      Sequence::difference_type jd = j;
      return alaqil::getslice(self, id, jd, step);
    }

    void __setitem__(PySliceObject *slice, const Sequence& v) throw (std::out_of_range, std::invalid_argument) {
      Py_ssize_t i, j, step;
      if( !PySlice_Check(slice) ) {
        alaqil_Error(alaqil_TypeError, "Slice object expected.");
        return;
      }
      PySlice_GetIndices(alaqilPY_SLICE_ARG(slice), (Py_ssize_t)self->size(), &i, &j, &step);
      Sequence::difference_type id = i;
      Sequence::difference_type jd = j;
      alaqil::setslice(self, id, jd, step, v);
    }

    void __setitem__(PySliceObject *slice) throw (std::out_of_range, std::invalid_argument) {
      Py_ssize_t i, j, step;
      if( !PySlice_Check(slice) ) {
        alaqil_Error(alaqil_TypeError, "Slice object expected.");
        return;
      }
      PySlice_GetIndices(alaqilPY_SLICE_ARG(slice), (Py_ssize_t)self->size(), &i, &j, &step);
      Sequence::difference_type id = i;
      Sequence::difference_type jd = j;
      alaqil::delslice(self, id, jd, step);
    }

    void __delitem__(PySliceObject *slice) throw (std::out_of_range, std::invalid_argument) {
      Py_ssize_t i, j, step;
      if( !PySlice_Check(slice) ) {
        alaqil_Error(alaqil_TypeError, "Slice object expected.");
        return;
      }
      PySlice_GetIndices(alaqilPY_SLICE_ARG(slice), (Py_ssize_t)self->size(), &i, &j, &step);
      Sequence::difference_type id = i;
      Sequence::difference_type jd = j;
      alaqil::delslice(self, id, jd, step);
    }

  }
%enddef

%define %alaqil_sequence_methods_non_resizable(Sequence...)
  %alaqil_sequence_methods_common(%arg(Sequence))
  %extend {
    const value_type& __getitem__(difference_type i) const throw (std::out_of_range) {
      return *(alaqil::cgetpos(self, i));
    }

    void __setitem__(difference_type i, const value_type& x) throw (std::out_of_range) {
      *(alaqil::getpos(self,i)) = x;
    }

#if defined(alaqilPYTHON_BUILTIN)
    // This will be called through the mp_ass_subscript slot to delete an entry.
    void __setitem__(difference_type i) throw (std::out_of_range, std::invalid_argument) {
      alaqil::erase(self, alaqil::getpos(self, i));
    }
#endif

  }
%enddef

%define %alaqil_sequence_methods(Sequence...)
  %alaqil_sequence_methods_non_resizable(%arg(Sequence))
  %extend {
    value_type pop() throw (std::out_of_range) {
      if (self->size() == 0)
	throw std::out_of_range("pop from empty container");
      Sequence::value_type x = self->back();
      self->pop_back();
      return x;
    }

    void append(const value_type& x) {
      self->push_back(x);
    }
  }
%enddef

%define %alaqil_sequence_methods_non_resizable_val(Sequence...)
  %alaqil_sequence_methods_common(%arg(Sequence))
  %extend {
    value_type __getitem__(difference_type i) throw (std::out_of_range) {
      return *(alaqil::cgetpos(self, i));
    }

    void __setitem__(difference_type i, value_type x) throw (std::out_of_range) {
      *(alaqil::getpos(self,i)) = x;
    }

#if defined(alaqilPYTHON_BUILTIN)
    // This will be called through the mp_ass_subscript slot to delete an entry.
    void __setitem__(difference_type i) throw (std::out_of_range, std::invalid_argument) {
      alaqil::erase(self, alaqil::getpos(self, i));
    }
#endif
  }
%enddef

%define %alaqil_sequence_methods_val(Sequence...)
  %alaqil_sequence_methods_non_resizable_val(%arg(Sequence))
  %extend {
    value_type pop() throw (std::out_of_range) {
      if (self->size() == 0)
	throw std::out_of_range("pop from empty container");
      Sequence::value_type x = self->back();
      self->pop_back();
      return x;
    }

    void append(value_type x) {
      self->push_back(x);
    }
  }
%enddef



//
// Common fragments
//

%fragment("StdSequenceTraits","header",
	  fragment="StdTraits",
	  fragment="alaqilPySequence_Cont")
{
namespace alaqil {
  template <class alaqilPySeq, class Seq>
  inline void
  assign(const alaqilPySeq& alaqilpyseq, Seq* seq) {
    // seq->assign(alaqilpyseq.begin(), alaqilpyseq.end()); // not used as not always implemented
    typedef typename alaqilPySeq::value_type value_type;
    typename alaqilPySeq::const_iterator it = alaqilpyseq.begin();
    for (;it != alaqilpyseq.end(); ++it) {
      seq->insert(seq->end(),(value_type)(*it));
    }
  }

  template <class Seq, class T = typename Seq::value_type >
  struct traits_asptr_stdseq {
    typedef Seq sequence;
    typedef T value_type;

    static int asptr(PyObject *obj, sequence **seq) {
      if (obj == Py_None || alaqil_Python_GetalaqilThis(obj)) {
	sequence *p;
	alaqil_type_info *descriptor = alaqil::type_info<sequence>();
	if (descriptor && alaqil_IsOK(::alaqil_ConvertPtr(obj, (void **)&p, descriptor, 0))) {
	  if (seq) *seq = p;
	  return alaqil_OLDOBJ;
	}
      } else if (PySequence_Check(obj)) {
	try {
	  alaqilPySequence_Cont<value_type> alaqilpyseq(obj);
	  if (seq) {
	    sequence *pseq = new sequence();
	    assign(alaqilpyseq, pseq);
	    *seq = pseq;
	    return alaqil_NEWOBJ;
	  } else {
	    return alaqilpyseq.check() ? alaqil_OK : alaqil_ERROR;
	  }
	} catch (std::exception& e) {
	  if (seq) {
	    if (!PyErr_Occurred()) {
	      PyErr_SetString(PyExc_TypeError, e.what());
	    }
	  }
	  return alaqil_ERROR;
	}
      }
      return alaqil_ERROR;
    }
  };

  template <class Seq, class T = typename Seq::value_type >
  struct traits_from_stdseq {
    typedef Seq sequence;
    typedef T value_type;
    typedef typename Seq::size_type size_type;
    typedef typename sequence::const_iterator const_iterator;

    static PyObject *from(const sequence& seq) {
%#ifdef alaqil_PYTHON_EXTRA_NATIVE_CONTAINERS
      alaqil_type_info *desc = alaqil::type_info<sequence>();
      if (desc && desc->clientdata) {
	return alaqil_InternalNewPointerObj(new sequence(seq), desc, alaqil_POINTER_OWN);
      }
%#endif
      size_type size = seq.size();
      if (size <= (size_type)INT_MAX) {
	PyObject *obj = PyTuple_New((Py_ssize_t)size);
	Py_ssize_t i = 0;
	for (const_iterator it = seq.begin(); it != seq.end(); ++it, ++i) {
	  PyTuple_SetItem(obj,i,alaqil::from<value_type>(*it));
	}
	return obj;
      } else {
	PyErr_SetString(PyExc_OverflowError,"sequence size not valid in python");
	return NULL;
      }
    }
  };
}
}
