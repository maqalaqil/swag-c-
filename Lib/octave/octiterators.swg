/* -----------------------------------------------------------------------------
 * octiterators.swg
 *
 * Users can derive form the OctalaqilIterator to implement their
 * own iterators. As an example (real one since we use it for STL/STD
 * containers), the template OctalaqilIterator_T does the
 * implementation for generic C++ iterators.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%fragment("OctalaqilIterator","header",fragment="<stddef.h>") {  
namespace alaqil {
  struct stop_iteration {
  };

  struct OctalaqilIterator {
  private:
    octave_value _seq;

  protected:
    OctalaqilIterator(octave_value seq) : _seq(seq)
    {
    }
      
  public:
    virtual ~OctalaqilIterator() {}

    virtual octave_value value() const = 0;

    virtual OctalaqilIterator *incr(size_t n = 1) = 0;

    virtual OctalaqilIterator *decr(size_t n = 1)
    {
      throw stop_iteration();
    }

    virtual ptrdiff_t distance(const OctalaqilIterator &x) const
    {
      throw std::invalid_argument("operation not supported");
    }

    virtual bool equal (const OctalaqilIterator &x) const
    {
      throw std::invalid_argument("operation not supported");
    }
    
    virtual OctalaqilIterator *copy() const = 0;

    octave_value next()
    {
      octave_value obj = value();
      incr();
      return obj;
    }

    octave_value previous()
    {
      decr();
      return value();
    }

    OctalaqilIterator *advance(ptrdiff_t n)
    {
      return  (n > 0) ?  incr(n) : decr(-n);
    }
      
    bool operator == (const OctalaqilIterator& x)  const
    {
      return equal(x);
    }
      
    bool operator != (const OctalaqilIterator& x) const
    {
      return ! operator==(x);
    }

    OctalaqilIterator* operator ++ () {
      incr();
      return this;
    }

    OctalaqilIterator* operator -- () {
      decr();
      return this;
    }
      
    OctalaqilIterator* operator + (ptrdiff_t n) const
    {
      return copy()->advance(n);
    }

    OctalaqilIterator* operator - (ptrdiff_t n) const
    {
      return copy()->advance(-n);
    }
      
    ptrdiff_t operator - (const OctalaqilIterator& x) const
    {
      return x.distance(*this);
    }
      
    static alaqil_type_info* descriptor() {
      static int init = 0;
      static alaqil_type_info* desc = 0;
      if (!init) {
	desc = alaqil_TypeQuery("alaqil::OctalaqilIterator *");
	init = 1;
      }	
      return desc;
    }    
  };
}
}

%fragment("OctalaqilIterator_T","header",fragment="<stddef.h>",fragment="OctalaqilIterator",fragment="StdTraits",fragment="StdIteratorTraits") {
namespace alaqil {
  template<typename OutIterator>
  class OctalaqilIterator_T :  public OctalaqilIterator
  {
  public:
    typedef OutIterator out_iterator;
    typedef typename std::iterator_traits<out_iterator>::value_type value_type;    
    typedef OctalaqilIterator_T<out_iterator> self_type;

    OctalaqilIterator_T(out_iterator curr, octave_value seq)
      : OctalaqilIterator(seq), current(curr)
    {
    }

    const out_iterator& get_current() const
    {
      return current;
    }

    
    bool equal (const OctalaqilIterator &iter) const
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return (current == iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }
    
    ptrdiff_t distance(const OctalaqilIterator &iter) const
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
    typedef octave_value result_type;
    result_type operator()(argument_type v) const
    {
      return alaqil::from(v);
    }
  };

  template<typename OutIterator, 
	   typename ValueType = typename std::iterator_traits<OutIterator>::value_type,
	   typename FromOper = from_oper<ValueType> >
  class OctalaqilIteratorOpen_T :  public OctalaqilIterator_T<OutIterator>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef OctalaqilIterator_T<out_iterator>  base;
    typedef OctalaqilIteratorOpen_T<OutIterator, ValueType, FromOper> self_type;
    
    OctalaqilIteratorOpen_T(out_iterator curr, octave_value seq)
      : OctalaqilIterator_T<OutIterator>(curr, seq)
    {
    }
    
    octave_value value() const {
      return from(static_cast<const value_type&>(*(base::current)));
    }
    
    OctalaqilIterator *copy() const
    {
      return new self_type(*this);
    }

    OctalaqilIterator *incr(size_t n = 1)
    {
      while (n--) {
	++base::current;
      }
      return this;
    }

    OctalaqilIterator *decr(size_t n = 1)
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
  class OctalaqilIteratorClosed_T :  public OctalaqilIterator_T<OutIterator>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef OctalaqilIterator_T<out_iterator>  base;    
    typedef OctalaqilIteratorClosed_T<OutIterator, ValueType, FromOper> self_type;
    
    OctalaqilIteratorClosed_T(out_iterator curr, out_iterator first, out_iterator last, octave_value seq)
      : OctalaqilIterator_T<OutIterator>(curr, seq), begin(first), end(last)
    {
    }
    
    octave_value value() const {
      if (base::current == end) {
	throw stop_iteration();
      } else {
	return from(static_cast<const value_type&>(*(base::current)));
      }
    }
    
    OctalaqilIterator *copy() const
    {
      return new self_type(*this);
    }

    OctalaqilIterator *incr(size_t n = 1)
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

    OctalaqilIterator *decr(size_t n = 1)
    {
      while (n--) {
	if (base::current == begin) {
	  throw stop_iteration();
	} else {
	  --base::current;
	}
      }
      return this;
    }

  private:
    out_iterator begin;
    out_iterator end;
  };

  template<typename OutIter>
  inline OctalaqilIterator*
  make_output_iterator(const OutIter& current, const OutIter& begin,const OutIter& end, octave_value seq = octave_value())
  {
    return new OctalaqilIteratorClosed_T<OutIter>(current, begin, end, seq);
  }

  template<typename OutIter>
  inline OctalaqilIterator*
  make_output_iterator(const OutIter& current, octave_value seq = octave_value())
  {
    return new OctalaqilIteratorOpen_T<OutIter>(current, seq);
  }
}
}


%fragment("OctalaqilIterator");
namespace alaqil 
{
// Throw a StopIteration exception
  %ignore stop_iteration;
  struct stop_iteration {};
  
  %typemap(throws) stop_iteration {
    error("stop_iteration exception");
    alaqil_fail;
  }

// Mark methods that return new objects
  %newobject OctalaqilIterator::copy;
  %newobject OctalaqilIterator::operator + (ptrdiff_t n) const;
  %newobject OctalaqilIterator::operator - (ptrdiff_t n) const;

  %nodirector OctalaqilIterator;

  %catches(alaqil::stop_iteration) OctalaqilIterator::value() const;
  %catches(alaqil::stop_iteration) OctalaqilIterator::incr(size_t n = 1);
  %catches(alaqil::stop_iteration) OctalaqilIterator::decr(size_t n = 1);
  %catches(std::invalid_argument) OctalaqilIterator::distance(const OctalaqilIterator &x) const;
  %catches(std::invalid_argument) OctalaqilIterator::equal (const OctalaqilIterator &x) const;
  %catches(alaqil::stop_iteration) OctalaqilIterator::next();
  %catches(alaqil::stop_iteration) OctalaqilIterator::previous();
  %catches(alaqil::stop_iteration) OctalaqilIterator::advance(ptrdiff_t n);
  %catches(alaqil::stop_iteration) OctalaqilIterator::operator += (ptrdiff_t n);
  %catches(alaqil::stop_iteration) OctalaqilIterator::operator -= (ptrdiff_t n);
  %catches(alaqil::stop_iteration) OctalaqilIterator::operator + (ptrdiff_t n) const;
  %catches(alaqil::stop_iteration) OctalaqilIterator::operator - (ptrdiff_t n) const;


  struct OctalaqilIterator
  {
  protected:
    OctalaqilIterator(octave_value seq);

  public:
    virtual ~OctalaqilIterator();

    virtual octave_value value() const = 0;

    virtual OctalaqilIterator *incr(size_t n = 1) = 0;
    
    virtual OctalaqilIterator *decr(size_t n = 1);

    virtual ptrdiff_t distance(const OctalaqilIterator &x) const;

    virtual bool equal (const OctalaqilIterator &x) const;
    
    virtual OctalaqilIterator *copy() const = 0;

    octave_value next();
    octave_value previous();
    OctalaqilIterator *advance(ptrdiff_t n);

    bool operator == (const OctalaqilIterator& x)  const;
    bool operator != (const OctalaqilIterator& x) const;
    OctalaqilIterator* operator ++ ();
    OctalaqilIterator* operator -- ();
    OctalaqilIterator* operator + (ptrdiff_t n) const;
    OctalaqilIterator* operator - (ptrdiff_t n) const;
    ptrdiff_t operator - (const OctalaqilIterator& x) const;
  };
}

