/* -----------------------------------------------------------------------------
 * pyiterators.swg
 *
 * Implement a python 'output' iterator for Python 2.2 or higher.
 *
 * Users can derive form the alaqilPyIterator to implement their
 * own iterators. As an example (real one since we use it for STL/STD
 * containers), the template alaqilPyIterator_T does the
 * implementation for generic C++ iterators.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%fragment("alaqilPyIterator","header",fragment="<stddef.h>") {
namespace alaqil {
  struct stop_iteration {
  };

  struct alaqilPyIterator {
  private:
    alaqilPtr_PyObject _seq;

  protected:
    alaqilPyIterator(PyObject *seq) : _seq(seq)
    {
    }
      
  public:
    virtual ~alaqilPyIterator() {}

    // Access iterator method, required by Python
    virtual PyObject *value() const = 0;

    // Forward iterator method, required by Python
    virtual alaqilPyIterator *incr(size_t n = 1) = 0;
    
    // Backward iterator method, very common in C++, but not required in Python
    virtual alaqilPyIterator *decr(size_t /*n*/ = 1)
    {
      throw stop_iteration();
    }

    // Random access iterator methods, but not required in Python
    virtual ptrdiff_t distance(const alaqilPyIterator &/*x*/) const
    {
      throw std::invalid_argument("operation not supported");
    }

    virtual bool equal (const alaqilPyIterator &/*x*/) const
    {
      throw std::invalid_argument("operation not supported");
    }
    
    // C++ common/needed methods
    virtual alaqilPyIterator *copy() const = 0;

    PyObject *next()     
    {
      alaqil_PYTHON_THREAD_BEGIN_BLOCK; // disable threads       
      PyObject *obj = value();
      incr();       
      alaqil_PYTHON_THREAD_END_BLOCK; // re-enable threads
      return obj;     
    }

    /* Make an alias for Python 3.x */
    PyObject *__next__()
    {
      return next();
    }

    PyObject *previous()
    {
      alaqil_PYTHON_THREAD_BEGIN_BLOCK; // disable threads       
      decr();
      PyObject *obj = value();
      alaqil_PYTHON_THREAD_END_BLOCK; // re-enable threads       
      return obj;
    }

    alaqilPyIterator *advance(ptrdiff_t n)
    {
      return  (n > 0) ?  incr(n) : decr(-n);
    }
      
    bool operator == (const alaqilPyIterator& x)  const
    {
      return equal(x);
    }
      
    bool operator != (const alaqilPyIterator& x) const
    {
      return ! operator==(x);
    }
      
    alaqilPyIterator& operator += (ptrdiff_t n)
    {
      return *advance(n);
    }

    alaqilPyIterator& operator -= (ptrdiff_t n)
    {
      return *advance(-n);
    }
      
    alaqilPyIterator* operator + (ptrdiff_t n) const
    {
      return copy()->advance(n);
    }

    alaqilPyIterator* operator - (ptrdiff_t n) const
    {
      return copy()->advance(-n);
    }
      
    ptrdiff_t operator - (const alaqilPyIterator& x) const
    {
      return x.distance(*this);
    }
      
    static alaqil_type_info* descriptor() {
      static int init = 0;
      static alaqil_type_info* desc = 0;
      if (!init) {
	desc = alaqil_TypeQuery("alaqil::alaqilPyIterator *");
	init = 1;
      }	
      return desc;
    }    
  };

%#if defined(alaqilPYTHON_BUILTIN)
  inline PyObject* make_output_iterator_builtin (PyObject *pyself)
  {
    Py_INCREF(pyself);
    return pyself;
  }
%#endif
}
}

%fragment("alaqilPyIterator_T","header",fragment="<stddef.h>",fragment="alaqilPyIterator",fragment="StdTraits",fragment="StdIteratorTraits") {
namespace alaqil {
  template<typename OutIterator>
  class alaqilPyIterator_T :  public alaqilPyIterator
  {
  public:
    typedef OutIterator out_iterator;
    typedef typename std::iterator_traits<out_iterator>::value_type value_type;    
    typedef alaqilPyIterator_T<out_iterator> self_type;

    alaqilPyIterator_T(out_iterator curr, PyObject *seq)
      : alaqilPyIterator(seq), current(curr)
    {
    }

    const out_iterator& get_current() const
    {
      return current;
    }

    
    bool equal (const alaqilPyIterator &iter) const
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return (current == iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }
    
    ptrdiff_t distance(const alaqilPyIterator &iter) const
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return std::distance(current, iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }    
    
  protected:
    out_iterator current;
  };
  
  template <class ValueType>
  struct from_oper 
  {
    typedef const ValueType& argument_type;
    typedef PyObject *result_type;
    result_type operator()(argument_type v) const
    {
      return alaqil::from(v);
    }
  };

  template<typename OutIterator, 
	   typename ValueType = typename std::iterator_traits<OutIterator>::value_type,
	   typename FromOper = from_oper<ValueType> >
  class alaqilPyForwardIteratorOpen_T :  public alaqilPyIterator_T<OutIterator>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef alaqilPyIterator_T<out_iterator>  base;
    typedef alaqilPyForwardIteratorOpen_T<OutIterator, ValueType, FromOper> self_type;
    
    alaqilPyForwardIteratorOpen_T(out_iterator curr, PyObject *seq)
      : alaqilPyIterator_T<OutIterator>(curr, seq)
    {
    }
    
    PyObject *value() const {
      return from(static_cast<const value_type&>(*(base::current)));
    }
    
    alaqilPyIterator *copy() const
    {
      return new self_type(*this);
    }

    alaqilPyIterator *incr(size_t n = 1)
    {
      while (n--) {
	++base::current;
      }
      return this;
    }

  };

  template<typename OutIterator, 
	   typename ValueType = typename std::iterator_traits<OutIterator>::value_type,
	   typename FromOper = from_oper<ValueType> >
  class alaqilPyIteratorOpen_T :  public alaqilPyForwardIteratorOpen_T<OutIterator, ValueType, FromOper>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef alaqilPyIterator_T<out_iterator>  base;
    typedef alaqilPyIteratorOpen_T<OutIterator, ValueType, FromOper> self_type;
    
    alaqilPyIteratorOpen_T(out_iterator curr, PyObject *seq)
      : alaqilPyForwardIteratorOpen_T<OutIterator>(curr, seq)
    {
    }

    alaqilPyIterator *decr(size_t n = 1)
    {
      while (n--) {
	--base::current;
      }
      return this;
    }
  };

  template<typename OutIterator, 
	   typename ValueType = typename std::iterator_traits<OutIterator>::value_type,
	   typename FromOper = from_oper<ValueType> >
  class alaqilPyForwardIteratorClosed_T :  public alaqilPyIterator_T<OutIterator>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef alaqilPyIterator_T<out_iterator>  base;    
    typedef alaqilPyForwardIteratorClosed_T<OutIterator, ValueType, FromOper> self_type;
    
    alaqilPyForwardIteratorClosed_T(out_iterator curr, out_iterator first, out_iterator last, PyObject *seq)
      : alaqilPyIterator_T<OutIterator>(curr, seq), begin(first), end(last)
    {
    }
    
    PyObject *value() const {
      if (base::current == end) {
	throw stop_iteration();
      } else {
	return from(static_cast<const value_type&>(*(base::current)));
      }
    }
    
    alaqilPyIterator *copy() const
    {
      return new self_type(*this);
    }

    alaqilPyIterator *incr(size_t n = 1)
    {
      while (n--) {
	if (base::current == end) {
	  throw stop_iteration();
	} else {
	  ++base::current;
	}
      }
      return this;
    }

  protected:
    out_iterator begin;
    out_iterator end;
  };

  template<typename OutIterator, 
	   typename ValueType = typename std::iterator_traits<OutIterator>::value_type,
	   typename FromOper = from_oper<ValueType> >
  class alaqilPyIteratorClosed_T :  public alaqilPyForwardIteratorClosed_T<OutIterator,ValueType,FromOper>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef alaqilPyIterator_T<out_iterator>  base;
    typedef alaqilPyForwardIteratorClosed_T<OutIterator, ValueType, FromOper> base0;
    typedef alaqilPyIteratorClosed_T<OutIterator, ValueType, FromOper> self_type;
    
    alaqilPyIteratorClosed_T(out_iterator curr, out_iterator first, out_iterator last, PyObject *seq)
      : alaqilPyForwardIteratorClosed_T<OutIterator,ValueType,FromOper>(curr, first, last, seq)
    {
    }

    alaqilPyIterator *decr(size_t n = 1)
    {
      while (n--) {
	if (base::current == base0::begin) {
	  throw stop_iteration();
	} else {
	  --base::current;
	}
      }
      return this;
    }
  };


  template<typename OutIter>
  inline alaqilPyIterator*
  make_output_forward_iterator(const OutIter& current, const OutIter& begin,const OutIter& end, PyObject *seq = 0)
  {
    return new alaqilPyForwardIteratorClosed_T<OutIter>(current, begin, end, seq);
  }

  template<typename OutIter>
  inline alaqilPyIterator*
  make_output_iterator(const OutIter& current, const OutIter& begin,const OutIter& end, PyObject *seq = 0)
  {
    return new alaqilPyIteratorClosed_T<OutIter>(current, begin, end, seq);
  }

  template<typename OutIter>
  inline alaqilPyIterator*
  make_output_forward_iterator(const OutIter& current, PyObject *seq = 0)
  {
    return new alaqilPyForwardIteratorOpen_T<OutIter>(current, seq);
  }

  template<typename OutIter>
  inline alaqilPyIterator*
  make_output_iterator(const OutIter& current, PyObject *seq = 0)
  {
    return new alaqilPyIteratorOpen_T<OutIter>(current, seq);
  }

}
}


%fragment("alaqilPyIterator");
namespace alaqil 
{
  /*
    Throw a StopIteration exception
  */
  %ignore stop_iteration;
  struct stop_iteration {};
  
  %typemap(throws) stop_iteration {
    (void)$1;
    alaqil_SetErrorObj(PyExc_StopIteration, alaqil_Py_Void());
    alaqil_fail;
  }

  /* 
     Mark methods that return new objects
  */
  %newobject alaqilPyIterator::copy;
  %newobject alaqilPyIterator::operator + (ptrdiff_t n) const;
  %newobject alaqilPyIterator::operator - (ptrdiff_t n) const;

  %nodirector alaqilPyIterator;

#if defined(alaqilPYTHON_BUILTIN)
  %feature("python:tp_iter") alaqilPyIterator "&alaqil::make_output_iterator_builtin";
  %feature("python:slot", "tp_iternext", functype="iternextfunc") alaqilPyIterator::__next__;
#else
  %extend alaqilPyIterator {
  %pythoncode %{def __iter__(self):
    return self%}
  }
#endif

  %catches(alaqil::stop_iteration) alaqilPyIterator::value() const;
  %catches(alaqil::stop_iteration) alaqilPyIterator::incr(size_t n = 1);
  %catches(alaqil::stop_iteration) alaqilPyIterator::decr(size_t n = 1);
  %catches(std::invalid_argument) alaqilPyIterator::distance(const alaqilPyIterator &x) const;
  %catches(std::invalid_argument) alaqilPyIterator::equal (const alaqilPyIterator &x) const;
  %catches(alaqil::stop_iteration) alaqilPyIterator::__next__();
  %catches(alaqil::stop_iteration) alaqilPyIterator::next();
  %catches(alaqil::stop_iteration) alaqilPyIterator::previous();
  %catches(alaqil::stop_iteration) alaqilPyIterator::advance(ptrdiff_t n);
  %catches(alaqil::stop_iteration) alaqilPyIterator::operator += (ptrdiff_t n);
  %catches(alaqil::stop_iteration) alaqilPyIterator::operator -= (ptrdiff_t n);
  %catches(alaqil::stop_iteration) alaqilPyIterator::operator + (ptrdiff_t n) const;
  %catches(alaqil::stop_iteration) alaqilPyIterator::operator - (ptrdiff_t n) const;

  struct alaqilPyIterator
  {
  protected:
    alaqilPyIterator(PyObject *seq);

  public:
    virtual ~alaqilPyIterator();

    // Access iterator method, required by Python
    virtual PyObject *value() const = 0;

    // Forward iterator method, required by Python
    virtual alaqilPyIterator *incr(size_t n = 1) = 0;
    
    // Backward iterator method, very common in C++, but not required in Python
    virtual alaqilPyIterator *decr(size_t n = 1);

    // Random access iterator methods, but not required in Python
    virtual ptrdiff_t distance(const alaqilPyIterator &x) const;

    virtual bool equal (const alaqilPyIterator &x) const;
    
    // C++ common/needed methods
    virtual alaqilPyIterator *copy() const = 0;

    PyObject *next();
    PyObject *__next__();
    PyObject *previous();
    alaqilPyIterator *advance(ptrdiff_t n);

    bool operator == (const alaqilPyIterator& x)  const;
    bool operator != (const alaqilPyIterator& x) const;
    alaqilPyIterator& operator += (ptrdiff_t n);
    alaqilPyIterator& operator -= (ptrdiff_t n);
    alaqilPyIterator* operator + (ptrdiff_t n) const;
    alaqilPyIterator* operator - (ptrdiff_t n) const;
    ptrdiff_t operator - (const alaqilPyIterator& x) const;
  };
}

