/* -----------------------------------------------------------------------------
 * scicontainer.swg
 *
 * Scilab list <-> C++ container wrapper
 *
 * This wrapper, and its iterator, allows a general use (and reuse) of
 * the mapping between C++ and Scilab, thanks to the C++ templates.
 *
 * Of course, it needs the C++ compiler to support templates, but
 * since we will use this wrapper with the STL containers, that should
 * be the case.
 * ----------------------------------------------------------------------------- */

%{
#include <iostream>
%}

#if !defined(alaqil_NO_EXPORT_ITERATOR_METHODS)
# if !defined(alaqil_EXPORT_ITERATOR_METHODS)
#  define alaqil_EXPORT_ITERATOR_METHODS alaqil_EXPORT_ITERATOR_METHODS
# endif
#endif


// #define (alaqil_SCILAB_EXTRA_NATIVE_CONTAINERS)
// if defined: sequences in return are converted from/to Scilab lists or matrices
// if not defined: sequences are passed from/to Scilab as pointers

%{
#define alaqil_STD_NOASSIGN_STL
%}

%include <sciiterators.swg>
%include <scisequence.swg>

%{
#include <stdexcept>
%}

%include <exception.i>
%include <std_except.i>

%fragment("SciSequence_Cont", "header",
	  fragment="StdTraits",
	  fragment="alaqilSciIterator_T",
	  fragment=alaqil_Traits_Sequence_frag(ptr),
	  fragment=alaqil_Traits_SequenceItem_frag(ptr))
{
namespace alaqil
{
  template <class T>
  struct SciSequence_Ref
  {
    SciSequence_Ref(const alaqilSciObject& seq, int index)
      : _seq(seq), _index(index)
    {
      if (traits_as_sequence<T>::get(_seq, &piSeqAddr) != alaqil_OK)
      {
        throw std::invalid_argument("Cannot get sequence data.");
      }
    }

    operator T () const
    {
      return traits_asval_sequenceitem<T>::asval(_seq, piSeqAddr, _index);
    }

    SciSequence_Ref& operator=(const T& v)
    {
      // TODO
      return *this;
    }

    private:
      alaqilSciObject _seq;
      int _index;
      void *piSeqAddr;
  };


  template <class T>
  struct SciSequence_ArrowProxy
  {
    SciSequence_ArrowProxy(const T& x): m_value(x) {}
    const T* operator->() const { return &m_value; }
    operator const T*() const { return &m_value; }
    T m_value;
  };

  template <class T, class Reference >
  struct alaqilSciSequence_InputIterator
  {
    typedef alaqilSciSequence_InputIterator<T, Reference > self;

    typedef std::random_access_iterator_tag iterator_category;
    typedef Reference reference;
    typedef T value_type;
    typedef T* pointer;
    typedef int difference_type;

    alaqilSciSequence_InputIterator()
    {
    }

    alaqilSciSequence_InputIterator(const alaqilSciObject& seq, int index)
      : _seq(seq), _index(index)
    {
    }

    reference operator*() const
    {
      return reference(_seq, _index);
    }

    SciSequence_ArrowProxy<T>
    operator->() const {
      return SciSequence_ArrowProxy<T>(operator*());
    }

    bool operator==(const self& ri) const
    {
      return (_index == ri._index);
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
    alaqilSciObject _seq;
    difference_type _index;
  };

  template <class T>
  struct SciSequence_Cont
  {
    typedef SciSequence_Ref<T> reference;
    typedef const SciSequence_Ref<T> const_reference;
    typedef T value_type;
    typedef T* pointer;
    typedef int difference_type;
    typedef int size_type;
    typedef const pointer const_pointer;
    typedef alaqilSciSequence_InputIterator<T, reference> iterator;
    typedef alaqilSciSequence_InputIterator<T, const_reference> const_iterator;

    SciSequence_Cont(const alaqilSciObject& seq) : _seq(seq)
    {
    }

    ~SciSequence_Cont()
    {
    }

    size_type size() const
    {
      int iSeqSize;
      if (traits_as_sequence<value_type>::size(_seq, &iSeqSize) == alaqil_OK)
      {
        return iSeqSize;
      }
      else
      {
        return alaqil_ERROR;
      }
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

  private:
    alaqilSciObject _seq;
  };
}
}

%define %alaqil_sequence_iterator(Sequence...)
#if defined(alaqil_EXPORT_ITERATOR_METHODS)
  class iterator;
  class reverse_iterator;
  class const_iterator;
  class const_reverse_iterator;

  %typemap(out,noblock=1,fragment="SciSequence_Cont")
    iterator, reverse_iterator, const_iterator, const_reverse_iterator {
    %set_output(alaqil_NewPointerObj(alaqil::make_output_iterator(%static_cast($1,const $type &)),
           alaqil::ScialaqilIterator::descriptor(),alaqil_POINTER_OWN));
  }
  %typemap(out,fragment="SciSequence_Cont")
    std::pair<iterator, iterator>, std::pair<const_iterator, const_iterator> {
    // TODO: return a Scilab list from the pair (see code for Octave)
  }

  %fragment("ScialaqilPairBoolOutputIterator", "header",
    fragment=alaqil_From_frag(bool), fragment="SciSequence_Cont") {}

  %typemap(out,fragment="ScialaqilPairBoolOutputIterator")
    std::pair<iterator, bool>, std::pair<const_iterator, bool> {
    // TODO: return a Scilab list from the pair (see code for Octave)
  }

  %typemap(in,noblock=1,fragment="SciSequence_Cont")
    iterator(alaqil::ScialaqilIterator *iter = 0, int res),
    reverse_iterator(alaqil::ScialaqilIterator *iter = 0, int res),
    const_iterator(alaqil::ScialaqilIterator *iter = 0, int res),
    const_reverse_iterator(alaqil::ScialaqilIterator *iter = 0, int res) {
    res = alaqil_ConvertPtr((alaqilSciObject)$input, %as_voidptrptr(&iter), alaqil::ScialaqilIterator::descriptor(), 0);
    if (!alaqil_IsOK(res) || !iter) {
      %argument_fail(alaqil_TypeError, "$type", $symname, $argnum);
    } else {
      alaqil::alaqilSciIterator_T<$type > *iter_t = dynamic_cast<alaqil::alaqilSciIterator_T<$type > *>(iter);
      if (iter_t) {
	$1 = iter_t->get_current();
      } else {
	%argument_fail(alaqil_TypeError, "$type", $symname, $argnum);
      }
    }
  }

  %typecheck(%checkcode(ITERATOR),noblock=1,fragment="SciSequence_Cont")
    iterator, reverse_iterator, const_iterator, const_reverse_iterator {
    alaqil::ScialaqilIterator *iter = 0;
    int res = alaqil_ConvertPtr((alaqilSciObject)$input, %as_voidptrptr(&iter), alaqil::ScialaqilIterator::descriptor(), 0);
    $1 = (alaqil_IsOK(res) && iter && (dynamic_cast<alaqil::alaqilSciIterator_T<$type > *>(iter) != 0));
  }

  %fragment("SciSequence_Cont");
#endif //alaqil_EXPORT_ITERATOR_METHODS
%enddef

// The Scilab container methods

%define %alaqil_container_methods(Container...)
%enddef

%define %alaqil_sequence_methods_common(Sequence...)
  %alaqil_sequence_iterator(%arg(Sequence))
  %alaqil_container_methods(%arg(Sequence))

%enddef

%define %alaqil_sequence_methods(Sequence...)
  %alaqil_sequence_methods_common(%arg(Sequence))
%enddef

%define %alaqil_sequence_methods_val(Sequence...)
  %alaqil_sequence_methods_common(%arg(Sequence))
%enddef

//
// Common fragments
//

%fragment("StdSequenceTraits","header",
	  fragment="StdTraits",
	  fragment="SciSequence_Cont")
{
namespace alaqil {
  template <class SciSeq, class Seq>
  inline void
  assign(const SciSeq& sciSeq, Seq* seq) {
%#ifdef alaqil_STD_NOASSIGN_STL
    typedef typename SciSeq::value_type value_type;
    typename SciSeq::const_iterator it = sciSeq.begin();
    for (;it != sciSeq.end(); ++it) {
      seq->insert(seq->end(),(value_type)(*it));
    }
%#else
    seq->assign(sciSeq.begin(), sciSeq.end());
%#endif
  }

  template <class Seq, class T = typename Seq::value_type >
  struct traits_asptr_stdseq {
    typedef Seq sequence;
    typedef T value_type;

    static int asptr(const alaqilSciObject& obj, sequence **seq)
    {
      alaqil_type_info *typeInfo = alaqil::type_info<sequence>();
      if (typeInfo)
      {
          sequence *p;
          if (alaqil_ConvertPtr(obj, (void**)&p, typeInfo, 0) == alaqil_OK)
          {
            if (seq)
              *seq = p;
            return alaqil_OLDOBJ;
          }
      }

      if (traits_as_sequence<value_type>::check(obj) == alaqil_OK)
      {
        try
        {
          SciSequence_Cont<value_type> sciSeq(obj);
          if (seq)
          {
            *seq = new sequence();
            assign(sciSeq, *seq);
            return alaqil_NEWOBJ;
          }
          else
          {
            return alaqil_ERROR;
          }
        }
        catch (std::exception& e)
        {
          alaqil_exception(alaqil_RuntimeError, e.what());
          return alaqil_ERROR;
        }
      }
      else 
      {
        return alaqil_ERROR;
      }
    }
  };

  template <class Seq, class T = typename Seq::value_type >
  struct traits_from_stdseq {
    typedef Seq sequence;
    typedef T value_type;
    typedef typename Seq::size_type size_type;
    typedef typename sequence::const_iterator const_iterator;

    static alaqilSciObject from(const sequence& seq)
    {
      %#ifdef alaqil_SCILAB_EXTRA_NATIVE_CONTAINERS
      alaqil_type_info *typeInfo = alaqil::type_info<sequence>();
      if (typeInfo)
      {
        return alaqil_NewPointerObj(new sequence(seq), typeInfo, alaqil_POINTER_OWN);
      }
      %#endif

      try
      {
        void *data;
        size_type size = seq.size();
        if (traits_from_sequence<value_type>::create(size, &data) == alaqil_OK) {
          const_iterator it;
          int index = 0;
          for (it = seq.begin(); it != seq.end(); ++it)
          {
            traits_from_sequenceitem<value_type>::from(data, index, *it);
            index++;
          }
          return traits_from_sequence<value_type>::set(size, data);
        }
        return alaqil_OK;
      }
      catch (std::exception& e)
      {
        alaqil_exception(alaqil_RuntimeError, e.what());
        return alaqil_ERROR;
      }
    }
  };
}
}
