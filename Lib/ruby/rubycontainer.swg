/* -----------------------------------------------------------------------------
 * rubycontainer.swg
 *
 * Ruby sequence <-> C++ container wrapper
 *
 * This wrapper, and its iterator, allows a general use (and reuse) of
 * the mapping between C++ and Ruby, thanks to the C++ templates.
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

%include <rubyiterators.swg>

/**** The RubySequence C++ Wrap ***/

%fragment("<stdexcept>");

%include <std_except.i>


%fragment("RubySequence_Base","header")
{
%#include <functional>


namespace alaqil {
  template < class T >
  struct yield
  {
    bool
    operator()( const T& v ) const
    { 
      return RTEST( rb_yield( alaqil::from< T >(v) ) );
    }
  };


  inline size_t
  check_index(ptrdiff_t i, size_t size, bool insert = false) {
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

  inline size_t
  slice_index(ptrdiff_t i, size_t size) {
    if ( i < 0 ) {
      if ((size_t) (-i) <= size) {
	return (size_t) (i + size);
      } else {
	throw std::out_of_range("index out of range");
      }
    } else {
      return ( (size_t) i < size ) ? ((size_t) i) : size;
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
  resize(Sequence *seq, typename Sequence::size_type n, typename Sequence::value_type x) {
    seq->resize(n, x);
  }

  template <class Sequence, class Difference>
  inline Sequence*
  getslice(const Sequence* self, Difference i, Difference j) {
    typename Sequence::size_type size = self->size();
    typename Sequence::size_type ii = alaqil::check_index(i, size, (i == size && j == size));
    typename Sequence::size_type jj = alaqil::slice_index(j, size);

    if (jj > ii) {
      typename Sequence::const_iterator vb = self->begin();
      typename Sequence::const_iterator ve = self->begin();
      std::advance(vb,ii);
      std::advance(ve,jj);
      return new Sequence(vb, ve);
    } else {
      return new Sequence();
    }
  }

  template <class Sequence, class Difference, class InputSeq>
  inline void
  setslice(Sequence* self, Difference i, Difference j, const InputSeq& v) {
    typename Sequence::size_type size = self->size();
    typename Sequence::size_type ii = alaqil::check_index(i, size, true);
    typename Sequence::size_type jj = alaqil::slice_index(j, size);
    if (jj < ii) jj = ii;
    size_t ssize = jj - ii;
    if (ssize <= v.size()) {
      typename Sequence::iterator sb = self->begin();
      typename InputSeq::const_iterator vmid = v.begin();
      std::advance(sb,ii);
      std::advance(vmid, jj - ii);
      self->insert(std::copy(v.begin(), vmid, sb), vmid, v.end());
    } else {
      typename Sequence::iterator sb = self->begin();
      typename Sequence::iterator se = self->begin();
      std::advance(sb,ii);
      std::advance(se,jj);
      self->erase(sb,se);
      self->insert(sb, v.begin(), v.end());
    }
  }

  template <class Sequence, class Difference>
  inline void
  delslice(Sequence* self, Difference i, Difference j) {
    typename Sequence::size_type size = self->size();
    typename Sequence::size_type ii = alaqil::check_index(i, size, true);
    typename Sequence::size_type jj = alaqil::slice_index(j, size);
    if (jj > ii) {
      typename Sequence::iterator sb = self->begin();
      typename Sequence::iterator se = self->begin();
      std::advance(sb,ii);
      std::advance(se,jj);
      self->erase(sb,se);
    }
  }
}
}

%fragment("RubySequence_Cont","header",
	  fragment="<stddef.h>",
	  fragment="StdTraits",
	  fragment="RubySequence_Base",
	  fragment="ConstIterator_T")
{
namespace alaqil
{

  /**
   * This class is a proxy class for references, used to return and set values
   * of an element of a Ruby Array of stuff.
   * It can be used by RubySequence_InputIterator to make it work with STL
   * algorithms.
   */
  template <class T>
  struct RubySequence_Ref
  {
    RubySequence_Ref(VALUE  seq, int index)
      : _seq(seq), _index(index)
    {
    }
    
    operator T () const
    {
      VALUE item = rb_ary_entry(_seq, _index );
      try {
	return alaqil::as<T>(item);
      } catch (const std::invalid_argument& e) {
	char msg[1024];
	sprintf(msg, "in sequence element %d ", _index);
	VALUE lastErr = rb_gv_get("$!");
	if ( lastErr == Qnil ) {
	  %type_error(alaqil::type_name<T>());
	}
	VALUE str = rb_str_new2(msg);
	str = rb_str_cat2( str, e.what() );
	alaqil_Ruby_ExceptionType( NULL, str );
	throw;
      }
    }

    RubySequence_Ref& operator=(const T& v)
    {
      rb_ary_set(_seq, _index, alaqil::from< T >(v));
      return *this;
    }

  private:
    VALUE  _seq;
    int _index;
  };


  /**
   * This class is a proxy to return a pointer to a class, usually
   * RubySequence_Ref. 
   * It can be used by RubySequence_InputIterator to make it work with STL
   * algorithms.
   */
  template <class T>
  struct RubySequence_ArrowProxy
  {
    RubySequence_ArrowProxy(const T& x): m_value(x) {}
    const T* operator->() const { return &m_value; }
    operator const T*() const { return &m_value; }
    T m_value;
  };


  /**
   * Input Iterator.  This adapator class is a random access iterator that 
   * allows you to use STL algorithms with a Ruby class (a Ruby Array by default).
   */
  template <class T, class Reference = RubySequence_Ref< T > >
  struct RubySequence_InputIterator
  {
    typedef RubySequence_InputIterator<T, Reference > self;

    typedef std::random_access_iterator_tag iterator_category;
    typedef Reference reference;
    typedef T value_type;
    typedef T* pointer;
    typedef ptrdiff_t difference_type;

    RubySequence_InputIterator()
    {
    }

    RubySequence_InputIterator(VALUE  seq, int index)
      : _seq(seq), _index(index)
    {
    }

    reference operator*() const
    {
      return reference(_seq, _index);
    }

    RubySequence_ArrowProxy<T>
    operator->() const {
      return RubySequence_ArrowProxy<T>(operator*());
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
    VALUE  _seq;
    difference_type _index;
  };


  /**
   * This adaptor class allows you to use a Ruby Array as if it was an STL
   * container, giving it begin(), end(), and iterators.
   */
  template <class T>
  struct RubySequence_Cont
  {
    typedef RubySequence_Ref<T> reference;
    typedef const RubySequence_Ref<T> const_reference;
    typedef T value_type;
    typedef T* pointer;
    typedef int difference_type;
    typedef int size_type;
    typedef const pointer const_pointer;
    typedef RubySequence_InputIterator<T, reference> iterator;
    typedef RubySequence_InputIterator<T, const_reference> const_iterator;

    RubySequence_Cont(VALUE  seq) : _seq(0)
    {
      if (!rb_obj_is_kind_of(seq, rb_cArray)) {
	throw std::invalid_argument("an Array is expected");
      }
      _seq = seq;
    }

    ~RubySequence_Cont()
    {
    }

    size_type size() const
    {
      return RARRAY_LEN(_seq);
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

    bool check(bool set_err = false) const
    {
      int s = (int) size();
      for (int i = 0; i < s; ++i) {
	VALUE item = rb_ary_entry(_seq, i );
	if (!alaqil::check<value_type>(item)) {
	  if (set_err) {
	    char msg[1024];
	    sprintf(msg, "in sequence element %d", i);
	    alaqil_Error(alaqil_RuntimeError, msg);
	  }
	  return false;
	}
      }
      return true;
    }

  private:
    VALUE  _seq;
  };

}
}

/** 
 * Macros used to typemap an STL iterator -> alaqilIterator conversion.
 */
%define %alaqil_sequence_iterator(Sequence...)
#if defined(alaqil_EXPORT_ITERATOR_METHODS)

  %typemap(out,noblock=1,fragment="RubySequence_Cont")
    const_iterator, const_reverse_iterator {
    $result = alaqil_NewPointerObj(alaqil::make_const_iterator(%static_cast($1,const $type &),
							   self),
				 alaqil::ConstIterator::descriptor(),alaqil_POINTER_OWN);
  }

  %typemap(out,noblock=1,fragment="RubySequence_Cont")
    iterator, reverse_iterator {
    $result = alaqil_NewPointerObj(alaqil::make_nonconst_iterator(%static_cast($1,const $type &),
							      self),
				 alaqil::Iterator::descriptor(),alaqil_POINTER_OWN);
  }

  %typemap(out,noblock=1,fragment="RubySequence_Cont")
    std::pair<const_iterator, const_iterator> {
    $result = rb_ary_new2(2);
    rb_ary_push($result, alaqil_NewPointerObj(alaqil::make_const_iterator(%static_cast($1,const $type &).first),
					    alaqil::ConstIterator::descriptor(),alaqil_POINTER_OWN));
    rb_ary_push($result, alaqil_NewPointerObj(alaqil::make_const_iterator(%static_cast($1,const $type &).second),
					    alaqil::ConstIterator::descriptor(),alaqil_POINTER_OWN));
  }

  // std::map/multimap/set allow returning std::pair< iterator, iterator > from
  // equal_range, but we cannot still modify the key, so the iterator is
  // const.
  %typemap(out,noblock=1,fragment="RubySequence_Cont")
    std::pair<iterator, iterator> {
    $result = rb_ary_new2(2);
    rb_ary_push($result, alaqil_NewPointerObj(alaqil::make_const_iterator(%static_cast($1,const $type &).first),
					    alaqil::ConstIterator::descriptor(),alaqil_POINTER_OWN));
    rb_ary_push($result, alaqil_NewPointerObj(alaqil::make_const_iterator(%static_cast($1,const $type &).second),
					    alaqil::ConstIterator::descriptor(),alaqil_POINTER_OWN));
  }


  %typemap(in,noblock=1,fragment="RubySequence_Cont")
    const_iterator(alaqil::ConstIterator *iter = 0, int res),
    const_reverse_iterator(alaqil::ConstIterator *iter = 0, int res) {
    res = alaqil_ConvertPtr($input, %as_voidptrptr(&iter), alaqil::ConstIterator::descriptor(), 0);
    if (!alaqil_IsOK(res) || !iter) {
      %argument_fail(alaqil_TypeError, "$type", $symname, $argnum);
    } else {
      alaqil::ConstIterator_T<$type > *iter_t = dynamic_cast<alaqil::ConstIterator_T<$type > *>(iter);
      if (iter_t) {
	$1 = iter_t->get_current();
      } else {
	%argument_fail(alaqil_TypeError, "$type", $symname, $argnum);
      }
    }
  }

  %typemap(in,noblock=1,fragment="RubySequence_Cont")
    iterator(alaqil::Iterator *iter = 0, int res),
    reverse_iterator(alaqil::Iterator *iter = 0, int res) {
    res = alaqil_ConvertPtr($input, %as_voidptrptr(&iter), alaqil::Iterator::descriptor(), 0);
    if (!alaqil_IsOK(res) || !iter) {
      %argument_fail(alaqil_TypeError, "$type", $symname, $argnum);
    } else {
      alaqil::Iterator_T<$type > *iter_t = dynamic_cast<alaqil::Iterator_T<$type > *>(iter);
      if (iter_t) {
	$1 = iter_t->get_current();
      } else {
	%argument_fail(alaqil_TypeError, "$type", $symname, $argnum);
      }
    }
  }

  %typecheck(%checkcode(ITERATOR),noblock=1,fragment="RubySequence_Cont")
    const_iterator, const_reverse_iterator {
    alaqil::ConstIterator *iter = 0;
    int res = alaqil_ConvertPtr($input, %as_voidptrptr(&iter), alaqil::ConstIterator::descriptor(), 0);
    $1 = (alaqil_IsOK(res) && iter && (dynamic_cast<alaqil::ConstIterator_T<$type > *>(iter) != 0));
  }

  %typecheck(%checkcode(ITERATOR),noblock=1,fragment="RubySequence_Cont")
    iterator, reverse_iterator {
    alaqil::ConstIterator *iter = 0;
    int res = alaqil_ConvertPtr($input, %as_voidptrptr(&iter), alaqil::Iterator::descriptor(), 0);
    $1 = (alaqil_IsOK(res) && iter && (dynamic_cast<alaqil::Iterator_T<$type > *>(iter) != 0));
  }

  %fragment("RubySequence_Cont");

//   %newobject iterator;
//   %newobject const_iterator;
//   %extend  {
//     alaqil::Iterator* iterator(VALUE* RUBY_SELF) {
//       return alaqil::make_nonconst_iterator($self->begin(), $self->begin(), 
// 				             $self->end(), *RUBY_SELF);
//     }

//     alaqil::ConstIterator* const_iterator(VALUE* RUBY_SELF) {
//       return alaqil::make_const_iterator($self->begin(), $self->begin(), 
// 					$self->end(), *RUBY_SELF);
//     }
//   }
#endif //alaqil_EXPORT_ITERATOR_METHODS
%enddef


/**** The Ruby container methods  ****/



%define %alaqil_container_methods(Container...)

  %extend {

  %newobject dup;
  Container* dup()
    {
      return new Container(*$self);
    }

  }

%enddef


/**
 * Macro used to define common Ruby printing methods for STL container
 */
%define %alaqil_sequence_printing_methods(Sequence...)

  %extend {

  VALUE inspect()
    {
      Sequence::const_iterator i = $self->begin();
      Sequence::const_iterator e = $self->end();
      const char *type_name = alaqil::type_name< Sequence >();
      VALUE str = rb_str_new2(type_name);
      str = rb_str_cat2( str, " [" );
      bool comma = false;
      VALUE tmp;
      for ( ; i != e; ++i, comma = true )
	{
	  if (comma) str = rb_str_cat2( str, "," );
	  tmp = alaqil::from< Sequence::value_type >( *i );
	  tmp = rb_inspect( tmp );
	  str = rb_str_buf_append( str, tmp );
	}
      str = rb_str_cat2( str, "]" );
      return str;
    }

  VALUE to_a()
    {
      Sequence::const_iterator i = $self->begin();
      Sequence::const_iterator e = $self->end();
      VALUE ary = rb_ary_new2( std::distance( i, e ) );
      VALUE tmp;
      for ( ; i != e; ++i )
	{
	  tmp = alaqil::from< Sequence::value_type >( *i );
	  rb_ary_push( ary, tmp );
	}
      return ary;
    }

  VALUE to_s()
    {
      Sequence::iterator i = $self->begin();
      Sequence::iterator e = $self->end();
      VALUE str = rb_str_new2( "" );
      VALUE tmp;
      for ( ; i != e; ++i )
	{
	  tmp = alaqil::from< Sequence::value_type >( *i );
	  tmp = rb_obj_as_string( tmp );
	  str = rb_str_buf_append( str, tmp );
	}
      return str;
    }
}
%enddef


/**
 * Macro used to add common methods to all STL sequence-type containers 
 */
%define %alaqil_sequence_methods_non_resizable_common(Sequence...)
  %alaqil_container_methods(%arg(Sequence))
  %alaqil_sequence_iterator(%arg(Sequence))
  %alaqil_sequence_printing_methods(%arg(Sequence))

  %fragment("RubySequence_Base");

  %extend {

  VALUE slice( difference_type i, difference_type length ) throw (std::invalid_argument) {
      if ( length < 0 )
        return Qnil;
      std::size_t len = $self->size();
      if ( i < 0 ) {
        if ( i + static_cast<Sequence::difference_type>(len) < 0 )
          return Qnil;
        else
          i = len + i;
      }
      Sequence::difference_type j = length + i;
      if ( j > static_cast<Sequence::difference_type>(len) )
        j = len;

      VALUE r = Qnil;
      try {
	r = alaqil::from< const Sequence* >( alaqil::getslice(self, i, j) );
      }
      catch( std::out_of_range ) {
      }
      return r;
    }


    Sequence* each()
      {
	if ( !rb_block_given_p() )
	  rb_raise( rb_eArgError, "no block given");

	VALUE r;
	Sequence::const_iterator i = self->begin();
	Sequence::const_iterator e = self->end();
	for ( ; i != e; ++i )
	  {
	    r = alaqil::from< Sequence::value_type >(*i);
	    rb_yield(r);
	  }
	
	return self;
      }

    VALUE __delete2__(const value_type& i) {
      VALUE r = Qnil;
      return r;
    }

  }
%enddef

%define %alaqil_sequence_methods_resizable_common(Sequence...)
  %extend {

    %newobject select;
    Sequence* select() {
      if ( !rb_block_given_p() )
	rb_raise( rb_eArgError, "no block given" );

      Sequence* r = new Sequence();
      Sequence::const_iterator i = $self->begin();
      Sequence::const_iterator e = $self->end();
      for ( ; i != e; ++i )
	{
	  VALUE v = alaqil::from< Sequence::value_type >(*i);
	  if ( RTEST( rb_yield(v) ) )
	    $self->insert( r->end(), *i);
	}
	
      return r;
    }

    VALUE delete_at(difference_type i) {
      VALUE r = Qnil;
      try {
	Sequence::iterator at = alaqil::getpos(self, i);
	r = alaqil::from< Sequence::value_type >( *(at) );
	$self->erase(at); 
      }
      catch (std::out_of_range)
	{
	}
      return r;
    }
  }
%enddef

%define %alaqil_sequence_methods_common(Sequence...)
  %alaqil_sequence_methods_non_resizable_common(%arg(Sequence))
  %alaqil_sequence_methods_resizable_common(%arg(Sequence))
%enddef

/**
 * Macro used to add functions for back insertion of values in
 * STL sequence containers
 */
%define %alaqil_sequence_back_inserters( Sequence... )
  %extend {

    VALUE pop() {
      if ($self->empty()) return Qnil;
      Sequence::value_type x = self->back();
      $self->pop_back();
      return alaqil::from< Sequence::value_type >( x );
    }

    %alias push "<<";
    const value_type push( const value_type& e ) {
      $self->push_back( e );
      return e;
    }

    %newobject reject;
    Sequence* reject() {
      if ( !rb_block_given_p() )
	rb_raise( rb_eArgError, "no block given" );

      Sequence* r = new Sequence();
      std::remove_copy_if( $self->begin(), $self->end(),              
			   std::back_inserter(*r),
			   alaqil::yield< Sequence::value_type >() );
      return r;
    }

  }
%enddef

%define %alaqil_sequence_methods_extra(Sequence...)
  %extend {
    %alias reject_bang "delete_if";
    Sequence* reject_bang() {
      if ( !rb_block_given_p() )
	rb_raise( rb_eArgError, "no block given" );

      $self->erase( std::remove_if( $self->begin(), $self->end(),
            alaqil::yield< Sequence::value_type >() ), $self->end() );
      return $self;
    }
  }
%enddef

%define %alaqil_sequence_methods_non_resizable_accessors(Sequence...)
  %extend {

    VALUE at(difference_type i) const {
      VALUE r = Qnil;
      try {
	r = alaqil::from< Sequence::value_type >( *(alaqil::cgetpos(self, i)) );
      }
      catch( std::out_of_range ) {
      }
      return r;
    }

    VALUE __getitem__(difference_type i, difference_type length) const throw (std::invalid_argument) {
      if ( length < 0 )
        return Qnil;
      std::size_t len = $self->size();
      if ( i < 0 ) {
        if ( i + static_cast<Sequence::difference_type>(len) < 0 )
          return Qnil;
        else
          i = len + i;
      }
      Sequence::difference_type j = length + i;
      if ( j > static_cast<Sequence::difference_type>(len) )
        j = len;

      VALUE r = Qnil;
      try {
	r = alaqil::from< const Sequence* >( alaqil::getslice(self, i, j) );
      }
      catch( std::out_of_range ) {
      }
      return r;
    }

    VALUE __getitem__(difference_type i) const {
      VALUE r = Qnil;
      try {
	r = alaqil::from< Sequence::value_type >( *(alaqil::cgetpos(self, i)) );
      }
      catch( std::out_of_range ) {
      }
      return r;
    }

    VALUE __getitem__(VALUE i) const throw (std::invalid_argument) {
      if ( rb_obj_is_kind_of( i, rb_cRange ) == Qfalse ) {
        rb_raise( rb_eTypeError, "not a valid index or range" );
      }

      static ID id_end   = rb_intern("end");
      static ID id_start = rb_intern("begin");
      static ID id_noend = rb_intern("exclude_end?");

      VALUE start = rb_funcall( i, id_start, 0 );
      VALUE end   = rb_funcall( i, id_end, 0 );
      bool  noend = ( rb_funcall( i, id_noend, 0 ) == Qtrue );

      int len = $self->size();

      int s = NUM2INT( start );
      if ( s < 0 ) {
        s = len + s;
        if ( s < 0 )
          return Qnil;
      } else if ( s > len )
        return Qnil;

      int e = NUM2INT( end );
      if ( e < 0 ) e = len + e;
      if ( noend ) e -= 1;
      if ( e < 0 ) e = -1;
      if ( e >= len ) e = len - 1;
      if ( s == len ) e = len - 1;

      return alaqil::from< Sequence* >( alaqil::getslice(self, s, e+1) );
    }

    VALUE __setitem__(difference_type i, const value_type& x) throw (std::invalid_argument, std::out_of_range)
      {
	if ( i >= static_cast<Sequence::difference_type>( $self->size()) )
          alaqil::resize( $self, i+1, x );
        else
          *(alaqil::getpos($self, i)) = x;

	return alaqil::from< Sequence::value_type >( x );
      }

    VALUE __setitem__(difference_type i, difference_type length, const Sequence& v) throw (std::invalid_argument) {

      if ( length < 0 )
        return Qnil;
      std::size_t len = $self->size();
      if ( i < 0 ) {
        if ( i + static_cast<Sequence::difference_type>(len) < 0 )
          return Qnil;
        else
          i = len + i;
      }
      Sequence::difference_type j = length + i;
      if ( j > static_cast<Sequence::difference_type>(len) ) {
        alaqil::resize( $self, j, *(v.begin()) );
      }

      VALUE r = Qnil;
      alaqil::setslice($self, i, j, v);
      r = alaqil::from< const Sequence* >( &v );
      return r;
    }
 }
%enddef

/**
 * Macro used to add functions for non resizable sequences
 */
%define %alaqil_sequence_methods_non_resizable(Sequence...)
  %alaqil_sequence_methods_non_resizable_common(%arg(Sequence))
  %alaqil_sequence_methods_non_resizable_accessors(%arg(Sequence))
%enddef


/**
 * Macro used to add functions for sequences
 */
%define %alaqil_sequence_methods(Sequence...)
  %alaqil_sequence_methods_non_resizable_common(%arg(Sequence))
  %alaqil_sequence_methods_resizable_common(%arg(Sequence))
  %alaqil_sequence_methods_non_resizable_accessors(%arg(Sequence))
  %alaqil_sequence_methods_extra(%arg(Sequence));
  %alaqil_sequence_back_inserters(%arg(Sequence));
%enddef

%define %alaqil_sequence_methods_non_resizable_val(Sequence...)
  %alaqil_sequence_methods_non_resizable(%arg(Sequence))
%enddef

%define %alaqil_sequence_methods_val(Sequence...)
  %alaqil_sequence_methods(%arg(Sequence))
%enddef


/**
 * Macro used to add functions for front insertion of
 * elements in STL sequence containers that support it.
 */
%define %alaqil_sequence_front_inserters( Sequence... )
%extend {

  VALUE shift()
    {
      if ($self->empty()) return Qnil;
      Sequence::value_type x = self->front();
      $self->erase( $self->begin() );
      return alaqil::from< Sequence::value_type >( x );
    }

  %typemap(in) (int argc, VALUE* argv) {
    $1 = argc - 1;
    $2 = argv + 1;
  }

  Sequence* insert( difference_type pos, int argc, VALUE* argv, ... )
    {
      std::size_t len = $self->size();
      std::size_t   i = alaqil::check_index( pos, len, true );
      Sequence::iterator start;

      VALUE elem = argv[0];
      int idx = 0;
      try {
	Sequence::value_type val = alaqil::as<Sequence::value_type>( elem );
	if ( i >= len ) {
	  $self->resize(i-1, val);
	  return $self;
	}
	start = $self->begin();
	std::advance( start, i );
	$self->insert( start++, val );

	for ( ++idx; idx < argc; ++idx )
	  {
	    elem = argv[idx];
	    val = alaqil::as<Sequence::value_type>( elem );
	    $self->insert( start++, val );
	  }

      } 
      catch(const std::invalid_argument &)
	{
	  rb_raise( rb_eArgError, "%s",
		    Ruby_Format_TypeError( "", 
					   alaqil::type_name<Sequence::value_type>(),
					   __FUNCTION__, idx+2, elem ));
	}


      return $self;
    }

  %typemap(in) (int argc, VALUE* argv) {
    $1 = argc;
    $2 = argv;
  }

  Sequence* unshift( int argc, VALUE* argv, ... )
    {
      for ( int idx = argc-1; idx >= 0; --idx )
	{
	  Sequence::iterator start = $self->begin();
	  VALUE elem = argv[idx];
	  try {
	    Sequence::value_type val = alaqil::as<Sequence::value_type>( elem );
	    $self->insert( start, val );
	  }
	  catch(const std::invalid_argument &)
	    {
	      rb_raise( rb_eArgError, "%s",
			Ruby_Format_TypeError( "", 
					       alaqil::type_name<Sequence::value_type>(),
					       __FUNCTION__, idx+2, elem ));
	    }
	}

      return $self;
    }
}
%enddef


//
// Common fragments
//

%fragment("StdSequenceTraits","header",
	  fragment="StdTraits",
	  fragment="RubySequence_Cont",
	  fragment="GC_VALUE_definition")
{
namespace alaqil {
  template <class RubySeq, class Seq>
  inline void
  assign(const RubySeq& rubyseq, Seq* seq) {
    // seq->assign(rubyseq.begin(), rubyseq.end()); // not used as not always implemented
    typedef typename RubySeq::value_type value_type;
    typename RubySeq::const_iterator it = rubyseq.begin();
    for (;it != rubyseq.end(); ++it) {
      seq->insert(seq->end(),(value_type)(*it));
    }
  }

  template <class Seq, class T = typename Seq::value_type >
  struct traits_asptr_stdseq {
    typedef Seq sequence;
    typedef T value_type;

    static int asptr(VALUE obj, sequence **seq) {
      if (rb_obj_is_kind_of(obj, rb_cArray) == Qtrue) {
	try {
	  RubySequence_Cont<value_type> rubyseq(obj);
	  if (seq) {
	    sequence *pseq = new sequence();
	    assign(rubyseq, pseq);
	    *seq = pseq;
	    return alaqil_NEWOBJ;
	  } else {
	    return rubyseq.check() ? alaqil_OK : alaqil_ERROR;
	  }
	} catch (std::exception& e) {
	  if (seq) {
	    VALUE lastErr = rb_gv_get("$!");
	    if (lastErr == Qnil) {
	      rb_raise(rb_eTypeError, "%s", e.what());
	    }
	  }
	  return alaqil_ERROR;
	}
      } else {
	sequence *p;
	alaqil_type_info *descriptor = alaqil::type_info<sequence>();
	if (descriptor && alaqil_IsOK(alaqil_ConvertPtr(obj, (void **)&p, descriptor, 0))) {
	  if (seq) *seq = p;
	  return alaqil_OLDOBJ;
	}
      }
      return alaqil_ERROR;
    }
  };

  // Partial specialization for GC_VALUE's.  No need to typecheck each
  // element.
  template< class Seq >
  struct traits_asptr_stdseq< Seq, alaqil::GC_VALUE > {
    typedef Seq sequence;
    typedef alaqil::GC_VALUE value_type;

    static int asptr(VALUE obj, sequence **seq) {
      if (rb_obj_is_kind_of(obj, rb_cArray) == Qtrue) {
	try {
	  if (seq) {
	    RubySequence_Cont<value_type> rubyseq(obj);
	    sequence *pseq = new sequence();
	    assign(rubyseq, pseq);
	    *seq = pseq;
	    return alaqil_NEWOBJ;
	  } else {
	    return true;
	  }
	} catch (std::exception& e) {
	  if (seq) {
	    VALUE lastErr = rb_gv_get("$!");
	    if (lastErr == Qnil) {
	      rb_raise(rb_eTypeError, "%s", e.what());
	    }
	  }
	  return alaqil_ERROR;
	}
      } else {
	sequence *p;
	alaqil_type_info *descriptor = alaqil::type_info<sequence>();
	if (descriptor && alaqil_IsOK(alaqil_ConvertPtr(obj, (void **)&p, descriptor, 0))) {
	  if (seq) *seq = p;
	  return alaqil_OLDOBJ;
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

    static VALUE from(const sequence& seq) {
#ifdef alaqil_RUBY_EXTRA_NATIVE_CONTAINERS
      alaqil_type_info *desc = alaqil::type_info<sequence>();
      if (desc && desc->clientdata) {
	return alaqil_NewPointerObj(new sequence(seq), desc, alaqil_POINTER_OWN);
      }
#endif
      size_type size = seq.size();
      if (size <= (size_type)INT_MAX) {
	VALUE obj = rb_ary_new2((int)size);
	int i = 0;
	for (const_iterator it = seq.begin();
	     it != seq.end(); ++it, ++i) {
	  rb_ary_push(obj, alaqil::from< value_type >(*it));
	}
	rb_obj_freeze(obj);  // treat as immutable result
	return obj;
      } else {
	rb_raise(rb_eRangeError,"sequence size not valid in ruby");
	return Qnil;
      }
    }
  };
}
}


%include <rubycontainer_extended.swg>
