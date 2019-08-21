%fragment("StdTraits","header",fragment="StdTraitsCommon")
{
namespace alaqil {  
  /*
    Traits that provides the from method
  */

  template <class Type> struct traits_from_ptr {
    static alaqil_Object from(Type *val, int owner = 0) {
      return alaqil_NewPointerObj(val, type_info<Type>(), owner);
    }
  };

  template <class Type> struct traits_from {
    static alaqil_Object from(const Type& val) {
      return traits_from_ptr<Type>::from(new Type(val), 1);
    }
  };

  template <class Type> struct traits_from<Type *> {
    static alaqil_Object from(Type* val) {
      return traits_from_ptr<Type>::from(val, 0);
    }
  };

  template <class Type>
  inline alaqil_Object from(const Type& val) {
    return traits_from<Type>::from(val);
  }

  template <class Type>
  inline alaqil_Object from_ptr(Type* val, int owner) {
    return traits_from_ptr<Type>::from(val, owner);
  }

  /*
    Traits that provides the asval/as/check method
  */
  template <class Type>
  struct traits_asptr {   
    static int asptr(alaqil_Object obj, Type **val) {
      Type *p = 0;
      alaqil_type_info *descriptor = type_info<Type>();
      int res = descriptor ? alaqil_ConvertPtr(obj, (void **)&p, descriptor, 0) : alaqil_ERROR;
      if (alaqil_IsOK(res)) {
	if (val) *val = p;
      }
      return res;
    }
  }; 

  template <class Type>
  inline int asptr(alaqil_Object obj, Type **vptr) {
    return traits_asptr<Type>::asptr(obj, vptr);
  }

  template <class Type> 
  struct traits_asval {
    static int asval(alaqil_Object obj, Type *val) {
      if (val) {
	Type *p = 0;
	int res = traits_asptr<Type>::asptr(obj, &p);
	if (!alaqil_IsOK(res)) return res;	
	if (p) {
	  typedef typename noconst_traits<Type>::noconst_type noconst_type;
	  *(const_cast<noconst_type*>(val)) = *p;
	  if (alaqil_IsNewObj(res)){
	    %delete(p);
	    res = alaqil_DelNewMask(res);
	  }
	  return res;
	} else {
	  return alaqil_ERROR;
	}
      } else {
	return traits_asptr<Type>::asptr(obj, (Type **)(0));
      }
    }
  };

  template <class Type> struct traits_asval<Type*> {
    static int asval(alaqil_Object obj, Type **val) {
      if (val) {
        typedef typename noconst_traits<Type>::noconst_type noconst_type;
        noconst_type *p = 0;
        int res = traits_asptr<noconst_type>::asptr(obj,  &p);
        if (alaqil_IsOK(res)) {
          *(const_cast<noconst_type**>(val)) = p;
	}
	return res;
      } else {
	return traits_asptr<Type>::asptr(obj, (Type **)(0));
      }
    }
  };
  
  template <class Type>
  inline int asval(alaqil_Object obj, Type *val) {
    return traits_asval<Type>::asval(obj, val);
  }

  template <class Type> 
  struct traits_as<Type, value_category> {
    static Type as(alaqil_Object obj) {
      Type v;
      int res = asval(obj, &v);
      if (!obj || !alaqil_IsOK(res)) {
        throw std::invalid_argument("bad type");
      }
      return v;
    }
  };

  template <class Type> 
  struct traits_as<Type, pointer_category> {
    static Type as(alaqil_Object obj) {
      Type *v = 0;      
      int res = (obj ? traits_asptr<Type>::asptr(obj, &v) : alaqil_ERROR);
      if (alaqil_IsOK(res) && v) {
	if (alaqil_IsNewObj(res)) {
	  Type r(*v);
	  %delete(v);
	  return r;
	} else {
	  return *v;
	}
      } else {
          throw std::invalid_argument("bad type");
      }
    }
  };

  template <class Type> 
  struct traits_as<Type*, pointer_category> {
    static Type* as(alaqil_Object obj, bool throw_error) {
      Type *v = 0;      
      int res = (obj ? traits_asptr<Type>::asptr(obj, &v) : alaqil_ERROR);
      if (alaqil_IsOK(res)) {
	return v;
      } else {
	if (throw_error)
          throw std::invalid_argument("bad type");
	return 0;
      }
    }
  };
    
  template <class Type>
  inline Type as(alaqil_Object obj) {
    return traits_as<Type, typename traits<Type>::category>::as(obj);
  }

  template <class Type> 
  struct traits_check<Type, value_category> {
    static bool check(alaqil_Object obj) {
      int res = obj ? asval(obj, (Type *)(0)) : alaqil_ERROR;
      return alaqil_IsOK(res) ? true : false;
    }
  };

  template <class Type> 
  struct traits_check<Type, pointer_category> {
    static bool check(alaqil_Object obj) {
      int res = obj ? asptr(obj, (Type **)(0)) : alaqil_ERROR;
      return alaqil_IsOK(res) ? true : false;
    }
  };

  template <class Type>
  inline bool check(alaqil_Object obj) {
    return traits_check<Type, typename traits<Type>::category>::check(obj);
  }
}
}

%define %specialize_std_container(Type,Check,As,From)
%{
namespace alaqil {
  template <>  struct traits_asval<Type > {   
    typedef Type value_type;
    static int asval(alaqil_Object obj, value_type *val) {
      if (Check(obj)) {
	if (val) *val = As(obj);
	return alaqil_OK;
      }
      return alaqil_ERROR;
    }
  };
  template <>  struct traits_from<Type > {
    typedef Type value_type;
    static alaqil_Object from(const value_type& val) {
      return From(val);
    }
  };

  template <> 
  struct traits_check<Type, value_category> {
    static int check(alaqil_Object obj) {
      int res = Check(obj);
      return obj && res ? res : 0;
    }
  };
}
%}
%enddef
