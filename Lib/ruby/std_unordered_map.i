//
//   Maps
//
%include <std_map.i>

%fragment("StdUnorderedMapTraits","header",fragment="StdMapCommonTraits")
{
  namespace alaqil {
    template <class RubySeq, class K, class T, class Hash, class Compare, class Alloc>
    inline void
    assign(const RubySeq& rubyseq, std::unordered_map<K,T,Hash,Compare,Alloc> *map) {
      typedef typename std::unordered_map<K,T,Hash,Compare,Alloc>::value_type value_type;
      typename RubySeq::const_iterator it = rubyseq.begin();
      for (;it != rubyseq.end(); ++it) {
	map->insert(value_type(it->first, it->second));
      }
    }

    template <class K, class T, class Hash, class Compare, class Alloc>
    struct traits_asptr<std::unordered_map<K,T,Hash,Compare,Alloc> >  {
      typedef std::unordered_map<K,T,Hash,Compare,Alloc> map_type;
      static int asptr(VALUE obj, map_type **val) {
	int res = alaqil_ERROR;
	if (TYPE(obj) == T_HASH) {
	  static ID id_to_a = rb_intern("to_a");
	  VALUE items = rb_funcall(obj, id_to_a, 0);
	  res = traits_asptr_stdseq<std::unordered_map<K,T,Hash,Compare,Alloc>, std::pair<K, T> >::asptr(items, val);
	} else {
	  map_type *p;
	  alaqil_type_info *descriptor = alaqil::type_info<map_type>();
	  res = descriptor ? alaqil_ConvertPtr(obj, (void **)&p, descriptor, 0) : alaqil_ERROR;
	  if (alaqil_IsOK(res) && val)  *val = p;
	}
	return res;
      }
    };

    template <class K, class T, class Hash, class Compare, class Alloc>
    struct traits_from<std::unordered_map<K,T,Hash,Compare,Alloc> >  {
      typedef std::unordered_map<K,T,Hash,Compare,Alloc> map_type;
      typedef typename map_type::const_iterator const_iterator;
      typedef typename map_type::size_type size_type;

      static VALUE from(const map_type& map) {
	alaqil_type_info *desc = alaqil::type_info<map_type>();
	if (desc && desc->clientdata) {
	  return alaqil_NewPointerObj(new map_type(map), desc, alaqil_POINTER_OWN);
	} else {
	  size_type size = map.size();
	  int rubysize = (size <= (size_type) INT_MAX) ? (int) size : -1;
	  if (rubysize < 0) {
	    alaqil_RUBY_THREAD_BEGIN_BLOCK;
	    rb_raise(rb_eRuntimeError, "map size not valid in Ruby");
	    alaqil_RUBY_THREAD_END_BLOCK;
	    return Qnil;
	  }
	  VALUE obj = rb_hash_new();
	  for (const_iterator i= map.begin(); i!= map.end(); ++i) {
	    VALUE key = alaqil::from(i->first);
	    VALUE val = alaqil::from(i->second);
	    rb_hash_aset(obj, key, val);
	  }
	  return obj;
	}
      }
    };
  }
}

#define %alaqil_unordered_map_common(Map...) %alaqil_map_common(Map)
#define %alaqil_unordered_map_methods(Map...) %alaqil_map_methods(Map)

%rename("delete")     std::unordered_map::__delete__;
%rename("reject!")    std::unordered_map::reject_bang;
%rename("map!")       std::unordered_map::map_bang;
%rename("empty?")     std::unordered_map::empty;
%rename("include?")   std::unordered_map::__contains__ const;
%rename("has_key?")   std::unordered_map::has_key const;

%mixin std::unordered_map "Enumerable";
%alias std::unordered_map::push          "<<";

%include <std/std_unordered_map.i>
