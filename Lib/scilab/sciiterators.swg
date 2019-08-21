/* -----------------------------------------------------------------------------
 * sciiterators.swg
 *
 * Users can derive form the ScialaqilIterator to implement their
 * own iterators. As an example (real one since we use it for STL/STD
 * containers), the template alaqilSciIterator_T does the
 * implementation for generic C++ iterators.
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%fragment("ScialaqilIterator","header",fragment="<stddef.h>") {
namespace alaqil {
  struct stop_iteration {
  };

  struct ScialaqilIterator {
  private:
    alaqilSciObject _seq;

  protected:
    ScialaqilIterator(alaqilSciObject seq) : _seq(seq)
    {
    }

  public:
    virtual ~ScialaqilIterator() {}

    virtual alaqilSciObject value() const = 0;

    virtual ScialaqilIterator *incr(size_t n = 1) = 0;

    virtual ScialaqilIterator *decr(size_t n = 1)
    {
      throw stop_iteration();
    }

    virtual ptrdiff_t distance(const ScialaqilIterator &x) const
    {
      throw std::invalid_argument("operation not supported");
    }

    virtual bool equal (const ScialaqilIterator &x) const
    {
      throw std::invalid_argument("operation not supported");
    }

    virtual ScialaqilIterator *copy() const = 0;

    alaqilSciObject next()
    {
      alaqilSciObject obj = value();
      incr();
      return obj;
    }

    alaqilSciObject previous()
    {
      decr();
      return value();
    }

    ScialaqilIterator *advance(ptrdiff_t n)
    {
      return  (n > 0) ?  incr(n) : decr(-n);
    }

    bool operator == (const ScialaqilIterator& x)  const
    {
      return equal(x);
    }

    bool operator != (const ScialaqilIterator& x) const
    {
      return ! operator==(x);
    }

    ScialaqilIterator* operator ++ () {
      incr();
      return this;
    }

    ScialaqilIterator* operator -- () {
      decr();
      return this;
    }

    ScialaqilIterator* operator + (ptrdiff_t n) const
    {
      return copy()->advance(n);
    }

    ScialaqilIterator* operator - (ptrdiff_t n) const
    {
      return copy()->advance(-n);
    }

    ptrdiff_t operator - (const ScialaqilIterator& x) const
    {
      return x.distance(*this);
    }

    static alaqil_type_info* descriptor() {
      static int init = 0;
      static alaqil_type_info* desc = 0;
      if (!init) {
	desc = alaqil_TypeQuery("alaqil::ScialaqilIterator *");
	init = 1;
      }
      return desc;
    }
  };
}
}

%fragment("alaqilSciIterator_T","header",fragment="<stddef.h>",fragment="ScialaqilIterator",fragment="StdTraits",fragment="StdIteratorTraits") {
namespace alaqil {
  template<typename OutIterator>
  class alaqilSciIterator_T :  public ScialaqilIterator
  {
  public:
    typedef OutIterator out_iterator;
    typedef typename std::iterator_traits<out_iterator>::value_type value_type;
    typedef alaqilSciIterator_T<out_iterator> self_type;

    alaqilSciIterator_T(out_iterator curr, alaqilSciObject seq)
      : ScialaqilIterator(seq), current(curr)
    {
    }

    const out_iterator& get_current() const
    {
      return current;
    }


    bool equal (const ScialaqilIterator &iter) const
    {
      const self_type *iters = dynamic_cast<const self_type *>(&iter);
      if (iters) {
	return (current == iters->get_current());
      } else {
	throw std::invalid_argument("bad iterator type");
      }
    }

    ptrdiff_t distance(const ScialaqilIterator &iter) const
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
    typedef alaqilSciObject result_type;
    result_type operator()(argument_type v) const
    {
      return alaqil::from(v);
    }
  };

  template<typename OutIterator,
	   typename ValueType = typename std::iterator_traits<OutIterator>::value_type,
	   typename FromOper = from_oper<ValueType> >
  class ScialaqilIteratorOpen_T :  public alaqilSciIterator_T<OutIterator>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef alaqilSciIterator_T<out_iterator>  base;
    typedef ScialaqilIteratorOpen_T<OutIterator, ValueType, FromOper> self_type;

    ScialaqilIteratorOpen_T(out_iterator curr, alaqilSciObject seq)
      : alaqilSciIterator_T<OutIterator>(curr, seq)
    {
    }

    alaqilSciObject value() const {
      return from(static_cast<const value_type&>(*(base::current)));
    }

    ScialaqilIterator *copy() const
    {
      return new self_type(*this);
    }

    ScialaqilIterator *incr(size_t n = 1)
    {
      while (n--) {
	++base::current;
      }
      return this;
    }

    ScialaqilIterator *decr(size_t n = 1)
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
  class ScialaqilIteratorClosed_T :  public alaqilSciIterator_T<OutIterator>
  {
  public:
    FromOper from;
    typedef OutIterator out_iterator;
    typedef ValueType value_type;
    typedef alaqilSciIterator_T<out_iterator>  base;
    typedef ScialaqilIteratorClosed_T<OutIterator, ValueType, FromOper> self_type;

    ScialaqilIteratorClosed_T(out_iterator curr, out_iterator first, out_iterator last, alaqilSciObject seq)
      : alaqilSciIterator_T<OutIterator>(curr, seq), begin(first), end(last)
    {
    }

    alaqilSciObject value() const {
      if (base::current == end) {
	throw stop_iteration();
      } else {
	return from(static_cast<const value_type&>(*(base::current)));
      }
    }

    ScialaqilIterator *copy() const
    {
      return new self_type(*this);
    }

    ScialaqilIterator *incr(size_t n = 1)
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

    ScialaqilIterator *decr(size_t n = 1)
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
  inline ScialaqilIterator*
  make_output_iterator(const OutIter& current, const OutIter& begin,const OutIter& end, alaqilSciObject seq = alaqilSciObject())
  {
    return new ScialaqilIteratorClosed_T<OutIter>(current, begin, end, seq);
  }

  template<typename OutIter>
  inline ScialaqilIterator*
  make_output_iterator(const OutIter& current, alaqilSciObject seq = alaqilSciObject())
  {
    return new ScialaqilIteratorOpen_T<OutIter>(current, seq);
  }
}
}


%fragment("ScialaqilIterator");
namespace alaqil
{
// Throw a StopIteration exception
  %ignore stop_iteration;
  struct stop_iteration {};

  %typemap(throws, noblock=1) stop_iteration
  {
    alaqil_Scilab_Raise(0, "stop_iteration", NULL);
    return alaqil_ERROR;
  }

// Mark methods that return new objects
  %newobject ScialaqilIterator::copy;
  %newobject ScialaqilIterator::operator + (ptrdiff_t n) const;
  %newobject ScialaqilIterator::operator - (ptrdiff_t n) const;

  %nodirector ScialaqilIterator;

  %catches(alaqil::stop_iteration) ScialaqilIterator::value() const;
  %catches(alaqil::stop_iteration) ScialaqilIterator::incr(size_t n = 1);
  %catches(alaqil::stop_iteration) ScialaqilIterator::decr(size_t n = 1);
  %catches(std::invalid_argument) ScialaqilIterator::distance(const ScialaqilIterator &x) const;
  %catches(std::invalid_argument) ScialaqilIterator::equal (const ScialaqilIterator &x) const;
  %catches(alaqil::stop_iteration) ScialaqilIterator::next();
  %catches(alaqil::stop_iteration) ScialaqilIterator::previous();
  %catches(alaqil::stop_iteration) ScialaqilIterator::advance(ptrdiff_t n);
  %catches(alaqil::stop_iteration) ScialaqilIterator::operator += (ptrdiff_t n);
  %catches(alaqil::stop_iteration) ScialaqilIterator::operator -= (ptrdiff_t n);
  %catches(alaqil::stop_iteration) ScialaqilIterator::operator + (ptrdiff_t n) const;
  %catches(alaqil::stop_iteration) ScialaqilIterator::operator - (ptrdiff_t n) const;

  %ignore ScialaqilIterator::operator==;
  %ignore ScialaqilIterator::operator!=;
  %ignore ScialaqilIterator::operator++;
  %ignore ScialaqilIterator::operator--;
  %ignore ScialaqilIterator::operator+;
  %ignore ScialaqilIterator::operator-;

  struct ScialaqilIterator
  {
  protected:
    ScialaqilIterator(alaqilSciObject seq);

  public:
    virtual ~ScialaqilIterator();

    virtual alaqilSciObject value() const = 0;

    virtual ScialaqilIterator *incr(size_t n = 1) = 0;

    virtual ScialaqilIterator *decr(size_t n = 1);

    virtual ptrdiff_t distance(const ScialaqilIterator &x) const;

    virtual bool equal (const ScialaqilIterator &x) const;

    virtual ScialaqilIterator *copy() const = 0;

    alaqilSciObject next();
    alaqilSciObject previous();
    ScialaqilIterator *advance(ptrdiff_t n);

    bool operator == (const ScialaqilIterator& x)  const;
    bool operator != (const ScialaqilIterator& x) const;
    ScialaqilIterator* operator ++ ();
    ScialaqilIterator* operator -- ();
    ScialaqilIterator* operator + (ptrdiff_t n) const;
    ScialaqilIterator* operator - (ptrdiff_t n) const;
    ptrdiff_t operator - (const ScialaqilIterator& x) const;
  };
}
