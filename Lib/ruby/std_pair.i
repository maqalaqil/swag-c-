/*
  Pairs
*/
%include <rubystdcommon.swg>

//#define alaqil_STD_PAIR_ASVAL

%fragment("StdPairTraits","header",fragment="StdTraits") {
  namespace alaqil {

    template <class T, class U >
    struct traits_asval<std::pair<T,U> >  {
      typedef std::pair<T,U> value_type;

      static int get_pair(VALUE first, VALUE second,
			  std::pair<T,U> *val)
      {
	if (val) {
	  T *pfirst = &(val->first);
	  int res1 = alaqil::asval((VALUE)first, pfirst);
	  if (!alaqil_IsOK(res1)) return res1;
	  U *psecond = &(val->second);
	  int res2 = alaqil::asval((VALUE)second, psecond);
	  if (!alaqil_IsOK(res2)) return res2;
	  return res1 > res2 ? res1 : res2;
	} else {
	  T *pfirst = 0;
	  int res1 = alaqil::asval((VALUE)first, pfirst);
	  if (!alaqil_IsOK(res1)) return res1;
	  U *psecond = 0;
	  int res2 = alaqil::asval((VALUE)second, psecond);
	  if (!alaqil_IsOK(res2)) return res2;
	  return res1 > res2 ? res1 : res2;
	}
      }

      static int asval(VALUE obj, std::pair<T,U> *val) {
	int res = alaqil_ERROR;
	if ( TYPE(obj) == T_ARRAY ) {
	  if (RARRAY_LEN(obj) == 2) {
	    VALUE first = rb_ary_entry(obj,0);
	    VALUE second = rb_ary_entry(obj,1);
	    res = get_pair(first, second, val);
	  }
	} else {
	  value_type *p;
	  alaqil_type_info *descriptor = alaqil::type_info<value_type>();
	  res = descriptor ? alaqil_ConvertPtr(obj, (void **)&p, descriptor, 0) : alaqil_ERROR;
	  if (alaqil_IsOK(res) && val)  *val = *p;
	}
	return res;
      }
    };

    template <class T, class U >
    struct traits_asptr<std::pair<T,U> >  {
      typedef std::pair<T,U> value_type;

      static int get_pair(VALUE first, VALUE second,
			  std::pair<T,U> **val) 
      {
	if (val) {
	  value_type *vp = %new_instance(std::pair<T,U>);
	  T *pfirst = &(vp->first);
	  int res1 = alaqil::asval((VALUE)first, pfirst);
	  if (!alaqil_IsOK(res1)) {
	    %delete(vp);
	    return res1;
	  }
	  U *psecond = &(vp->second);
	  int res2 = alaqil::asval((VALUE)second, psecond);
	  if (!alaqil_IsOK(res2)) {
	    %delete(vp);
	    return res2;
	  }
	  *val = vp;
	  return alaqil_AddNewMask(res1 > res2 ? res1 : res2);
	} else {
	  T *pfirst = 0;
	  int res1 = alaqil::asval((VALUE)first, pfirst);
	  if (!alaqil_IsOK(res1)) return res1;
	  U *psecond = 0;
	  int res2 = alaqil::asval((VALUE)second, psecond);
	  if (!alaqil_IsOK(res2)) return res2;
	  return res1 > res2 ? res1 : res2;
	}
      }

      static int asptr(VALUE obj, std::pair<T,U> **val) {
	int res = alaqil_ERROR;
	if ( TYPE(obj) == T_ARRAY ) {
	  if ( RARRAY_LEN(obj) == 2) {
	    VALUE first = rb_ary_entry(obj,0);
	    VALUE second = rb_ary_entry(obj,1);
	    res = get_pair(first, second, val);
	  }
	} else {
	  value_type *p;
	  alaqil_type_info *descriptor = alaqil::type_info<value_type>();
	  res = descriptor ? alaqil_ConvertPtr(obj, (void **)&p, descriptor, 0) : alaqil_ERROR;
	  if (alaqil_IsOK(res) && val)  *val = p;
	}
	return res;
      }
    };



    template <class T, class U >
    struct traits_from<std::pair<T,U> >   {
      static VALUE _wrap_pair_second( VALUE self )
      {
	std::pair< typename alaqil::noconst_traits<T >::noconst_type,U>* p = NULL;
	alaqil::asptr( self, &p );
	return alaqil::from( p->second );
      }

      static VALUE _wrap_pair_second_eq( VALUE self, VALUE arg )
      {
	std::pair< typename alaqil::noconst_traits<T >::noconst_type,U>* p = NULL;
	alaqil::asptr( self, &p );
	return alaqil::from( p->second );
      }

      static VALUE from(const std::pair<T,U>& val) {
	VALUE obj = rb_ary_new2(2);
	rb_ary_push(obj, alaqil::from<typename alaqil::noconst_traits<T >::noconst_type>(val.first));
	rb_ary_push(obj, alaqil::from(val.second));
	rb_define_singleton_method(obj, "second",
				   VALUEFUNC(_wrap_pair_second), 0 );
	rb_define_singleton_method(obj, "second=",
				   VALUEFUNC(_wrap_pair_second_eq), 1 );
	rb_obj_freeze(obj); // treat as immutable tuple
	return obj;
      }
    };

  }
}

// Missing typemap
%typemap(in) std::pair* (int res) {
  res = alaqil::asptr( $input, &$1 );
  if (!alaqil_IsOK(res))
    %argument_fail(res, "$1_type", $symname, $argnum); 
}


%define %alaqil_pair_methods(pair...)

%extend { 
  VALUE inspect() const
    {
      VALUE tmp;
      const char *type_name = alaqil::type_name< pair >();
      VALUE str = rb_str_new2( type_name );
      str = rb_str_cat2( str, " (" );
      tmp = alaqil::from( $self->first );
      tmp = rb_obj_as_string( tmp );
      str = rb_str_buf_append( str, tmp );
      str = rb_str_cat2( str, "," );
      tmp = alaqil::from( $self->second );
      tmp = rb_obj_as_string( tmp );
      str = rb_str_buf_append( str, tmp );
      str = rb_str_cat2( str, ")" );
      return str;
    }

  VALUE to_s() const
    {
      VALUE tmp;
      VALUE str = rb_str_new2( "(" );
      tmp = alaqil::from( $self->first );
      tmp = rb_obj_as_string( tmp );
      str = rb_str_buf_append( str, tmp );
      str = rb_str_cat2( str, "," );
      tmp = alaqil::from( $self->second );
      tmp = rb_obj_as_string( tmp );
      str = rb_str_buf_append( str, tmp );
      str = rb_str_cat2( str, ")" );
      return str;
    }

  VALUE __getitem__( int index )
    { 
      if (( index % 2 ) == 0 )
	return alaqil::from( $self->first );
      else
	return alaqil::from( $self->second );
    }

  VALUE __setitem__( int index, VALUE obj )
    { 
      int res;
      if (( index % 2 ) == 0 )
	{
	  res = alaqil::asval( obj, &($self->first) );
	}
      else
	{
	  res = alaqil::asval(obj, &($self->second) );
	}
      if (!alaqil_IsOK(res))
	rb_raise( rb_eArgError, "invalid item for " #pair );
      return obj;
    }

  } // extend

%enddef

%include <std/std_pair.i>
