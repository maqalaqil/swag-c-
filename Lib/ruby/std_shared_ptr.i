#define alaqil_SHARED_PTR_NAMESPACE std
%include <boost_shared_ptr.i>
%include <rubystdcommon_forward.swg>


%fragment("StdSharedPtrTraits","header",fragment="StdTraitsForwardDeclaration",fragment="<memory>")
{
namespace alaqil {
  /*
   Template specialization for functions defined in rubystdcommon.swg. Special handling for shared_ptr
   is required as, shared_ptr<T> * is used rather than the usual T *, see shared_ptr.i.
  */
  template <class Type>
  struct traits_asptr<std::shared_ptr<Type> > {
    static int asptr(VALUE obj, std::shared_ptr<Type> **val) {
      std::shared_ptr<Type> *p = 0;
      alaqil_type_info *descriptor = type_info<std::shared_ptr<Type> >();
      alaqil_ruby_owntype newmem = {0, 0};
      int res = descriptor ? alaqil_ConvertPtrAndOwn(obj, (void **)&p, descriptor, 0, &newmem) : alaqil_ERROR;
      if (alaqil_IsOK(res)) {
	if (val) {
	  if (*val) {
	    **val = p ? *p : std::shared_ptr<Type>();
	  } else {
	    *val = p;
	    if (newmem.own & alaqil_CAST_NEW_MEMORY) {
	      // Upcast for pointers to shared_ptr in this generic framework has not been implemented
	      res = alaqil_ERROR;
	    }
	  }
	}
	if (newmem.own & alaqil_CAST_NEW_MEMORY)
	  delete p;
      }
      return res;
    }
  };

  template <class Type>
  struct traits_asval<std::shared_ptr<Type> > {
    static int asval(VALUE obj, std::shared_ptr<Type> *val) {
      if (val) {
	std::shared_ptr<Type> ret;
	std::shared_ptr<Type> *p = &ret;
	int res = traits_asptr<std::shared_ptr<Type> >::asptr(obj, &p);
	if (!alaqil_IsOK(res))
	  return res;
	*val = ret;
	return alaqil_OK;
      } else {
	return traits_asptr<std::shared_ptr<Type> >::asptr(obj, (std::shared_ptr<Type> **)(0));
      }
    }
  };

  template <class Type>
    struct traits_asval<std::shared_ptr<Type> *> {
    static int asval(VALUE obj, std::shared_ptr<Type> **val) {
      if (val) {
	typedef typename noconst_traits<std::shared_ptr<Type> >::noconst_type noconst_type;
	if (*val) {
	  noconst_type ret;
	  noconst_type *p = &ret;
	  int res = traits_asptr<noconst_type>::asptr(obj, &p);
	  if (alaqil_IsOK(res))
	    **(const_cast<noconst_type**>(val)) = ret;
	  return res;
	} else {
	  noconst_type *p = 0;
	  int res = traits_asptr<noconst_type>::asptr(obj,  &p);
	  if (alaqil_IsOK(res))
	    *val = p;
	  return res;
	}
      } else {
	return traits_asptr<std::shared_ptr<Type> >::asptr(obj, (std::shared_ptr<Type> **)(0));
      }
    }
  };

  template <class Type>
  struct traits_as<std::shared_ptr<Type>, pointer_category> {
    static std::shared_ptr<Type> as(VALUE obj) {
      std::shared_ptr<Type> ret;
      std::shared_ptr<Type> *v = &ret;
      int res = traits_asptr<std::shared_ptr<Type> >::asptr(obj, &v);
      if (alaqil_IsOK(res)) {
	return ret;
      } else {
	
	VALUE lastErr = rb_gv_get("$!");
	if (lastErr == Qnil)
	  alaqil_Error(alaqil_TypeError,  alaqil::type_name<std::shared_ptr<Type> >());
        throw std::invalid_argument("bad type");
      }
    }
  };

  template <class Type>
  struct traits_as<std::shared_ptr<Type> *, pointer_category> {
    static std::shared_ptr<Type> * as(VALUE obj) {
      std::shared_ptr<Type> *p = 0;
      int res = traits_asptr<std::shared_ptr<Type> >::asptr(obj, &p);
      if (alaqil_IsOK(res)) {
	return p;
      } else {
	
	VALUE lastErr = rb_gv_get("$!");
	if (lastErr == Qnil)
	  alaqil_Error(alaqil_TypeError,  alaqil::type_name<std::shared_ptr<Type> *>());
        throw std::invalid_argument("bad type");
      }
    }
  };

  template <class Type>
  struct traits_from_ptr<std::shared_ptr<Type> > {
    static VALUE from(std::shared_ptr<Type> *val, int owner = 0) {
      if (val && *val) {
        return alaqil_NewPointerObj(val, type_info<std::shared_ptr<Type> >(), owner);
      } else {
        return Qnil;
      }
    }
  };

  /*
   The descriptors in the shared_ptr typemaps remove the const qualifier for the alaqil type system.
   Remove const likewise here, otherwise alaqil_TypeQuery("std::shared_ptr<const Type>") will return NULL.
  */
  template<class Type>
  struct traits_from<std::shared_ptr<const Type> > {
    static VALUE from(const std::shared_ptr<const Type>& val) {
      std::shared_ptr<Type> p = std::const_pointer_cast<Type>(val);
      return alaqil::from(p);
    }
  };
}
}

%fragment("StdSharedPtrTraits");
