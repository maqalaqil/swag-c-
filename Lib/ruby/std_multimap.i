/*
  Multimaps
*/
%include <std_map.i>

%fragment("StdMultimapTraits","header",fragment="StdMapCommonTraits")
{
  namespace alaqil {
    template <class RubySeq, class K, class T >
    inline void 
    assign(const RubySeq& rubyseq, std::multimap<K,T > *multimap) {
      typedef typename std::multimap<K,T>::value_type value_type;
      typename RubySeq::const_iterator it = rubyseq.begin();
      for (;it != rubyseq.end(); ++it) {
	multimap->insert(value_type(it->first, it->second));
      }
    }

    template <class K, class T>
    struct traits_asptr<std::multimap<K,T> >  {
      typedef std::multimap<K,T> multimap_type;
      static int asptr(VALUE obj, std::multimap<K,T> **val) {
	int res = alaqil_ERROR;
	if ( TYPE(obj) == T_HASH ) {
	  static ID id_to_a = rb_intern("to_a");
	  VALUE items = rb_funcall(obj, id_to_a, 0);
	  return traits_asptr_stdseq<std::multimap<K,T>, std::pair<K, T> >::asptr(items, val);
	} else {
	  multimap_type *p;
	  res = alaqil_ConvertPtr(obj,(void**)&p,alaqil::type_info<multimap_type>(),0);
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
            
      static VALUE from(const multimap_type& multimap) {
	alaqil_type_info *desc = alaqil::type_info<multimap_type>();
	if (desc && desc->clientdata) {
	  return alaqil_NewPointerObj(new multimap_type(multimap), desc, alaqil_POINTER_OWN);
	} else {
	  size_type size = multimap.size();
	  int rubysize = (size <= (size_type) INT_MAX) ? (int) size : -1;
	  if (rubysize < 0) {
	    alaqil_RUBY_THREAD_BEGIN_BLOCK;
	    rb_raise(rb_eRuntimeError,
		     "multimap size not valid in Ruby");
	    alaqil_RUBY_THREAD_END_BLOCK;
	    return Qnil;
	  }
	  VALUE obj = rb_hash_new();
	  for (const_iterator i= multimap.begin(); i!= multimap.end(); ++i) {
	    VALUE key = alaqil::from(i->first);
	    VALUE val = alaqil::from(i->second);

	    VALUE oldval = rb_hash_aref( obj, key );
	    if ( oldval == Qnil )
	      rb_hash_aset(obj, key, val);
	    else {
	      // Multiple values for this key, create array if needed
	      // and add a new element to it.
	      VALUE ary;
	      if ( TYPE(oldval) == T_ARRAY )
		ary = oldval;
	      else
		{
		  ary = rb_ary_new2(2);
		  rb_ary_push( ary, oldval );
		  rb_hash_aset( obj, key, ary );
		}
	      rb_ary_push( ary, val );
	    }
	    
	  }
	  return obj;
	}
      }
    };
  }
}

%define %alaqil_multimap_methods(MultiMap...) 
  %alaqil_map_common(%arg(MultiMap));

  %extend {
    VALUE __getitem__(const key_type& key) const {
      std::pair<MultiMap::const_iterator, MultiMap::const_iterator > r = $self->equal_range(key);
      if ( r.first != r.second )
	{
	  VALUE ary = rb_ary_new();
	  for (MultiMap::const_iterator i = r.first ; i != r.second; ++i )
	    {
	      rb_ary_push( ary, alaqil::from<MultiMap::mapped_type>( i->second ) );
	    }
	  if ( RARRAY_LEN(ary) == 1 )
	    return RARRAY_PTR(ary)[0];
	  return ary;
	}
      else
	return Qnil;
    }

    void __setitem__(const key_type& key, const mapped_type& x) throw (std::out_of_range) {
      self->insert(MultiMap::value_type(key,x));
    }

  VALUE inspect()
    {
      MultiMap::iterator i = $self->begin();
      MultiMap::iterator e = $self->end();
      const char *type_name = alaqil::type_name< MultiMap >();
      VALUE str = rb_str_new2( type_name );
      str = rb_str_cat2( str, " {" );
      VALUE tmp;
      while ( i != e )
	{
	  const MultiMap::key_type& key    = i->first;
	  const MultiMap::key_type& oldkey = key;
	  tmp = alaqil::from( key );
	  str = rb_str_buf_append( str, rb_inspect(tmp) );
	  str = rb_str_cat2( str, "=>" );

	  VALUE vals = rb_ary_new();
	  for ( ; i != e && key == oldkey; ++i )
	    {
	      const MultiMap::mapped_type& val = i->second;
	      tmp = alaqil::from( val );
	      rb_ary_push( vals, tmp );
	    }

	  if ( RARRAY_LEN(vals) == 1 )
	    {
	      str = rb_str_buf_append( str, rb_inspect(tmp) );
	    }
	  else
	    {
	      str = rb_str_buf_append( str, rb_inspect(vals) );
	    }
	}
      str = rb_str_cat2( str, "}" );
      return str;
    }

  VALUE to_a()
    {
      MultiMap::const_iterator i = $self->begin();
      MultiMap::const_iterator e = $self->end();
      VALUE ary = rb_ary_new2( std::distance( i, e ) );
      VALUE tmp;
      while ( i != e )
	{
	  const MultiMap::key_type& key    = i->first;
	  const MultiMap::key_type& oldkey = key;
	  tmp = alaqil::from( key );
	  rb_ary_push( ary, tmp );

	  VALUE vals = rb_ary_new();
	  for ( ; i != e && key == oldkey; ++i )
	    {
	      const MultiMap::mapped_type& val = i->second;
	      tmp = alaqil::from( val );
	      rb_ary_push( vals, tmp );
	    }

	  if ( RARRAY_LEN(vals) == 1 )
	    {
	      rb_ary_push( ary, tmp );
	    }
	  else
	    {
	      rb_ary_push( ary, vals );
	    }
	}
      return ary;
    }

  VALUE to_s()
    {
      MultiMap::iterator i = $self->begin();
      MultiMap::iterator e = $self->end();
      VALUE str = rb_str_new2( "" );
      VALUE tmp;
      while ( i != e )
	{
	  const MultiMap::key_type& key    = i->first;
	  const MultiMap::key_type& oldkey = key;
	  tmp = alaqil::from( key );
	  tmp = rb_obj_as_string( tmp );
	  str = rb_str_buf_append( str, tmp );

	  VALUE vals = rb_ary_new();
	  for ( ; i != e && key == oldkey; ++i )
	    {
	      const MultiMap::mapped_type& val = i->second;
	      tmp = alaqil::from( val );
	      rb_ary_push( vals, tmp );
	    }

	  tmp = rb_obj_as_string( vals );
	  str = rb_str_buf_append( str, tmp );
	}
      return str;
    }
  }
%enddef


%mixin std::multimap "Enumerable";

%rename("delete")     std::multimap::__delete__;
%rename("reject!")    std::multimap::reject_bang;
%rename("map!")       std::multimap::map_bang;
%rename("empty?")     std::multimap::empty;
%rename("include?" )  std::multimap::__contains__ const;
%rename("has_key?" )  std::multimap::has_key const;

%alias  std::multimap::push          "<<";

%include <std/std_multimap.i>

