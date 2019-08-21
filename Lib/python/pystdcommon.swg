%fragment("StdTraits","header",fragment="StdTraitsCommon")
{
namespace alaqil {  
  /*
    Traits that provides the from method
  */
  template <class Type> struct traits_from_ptr {
    static PyObject *from(Type *val, int owner = 0) {
      return alaqil_InternalNewPointerObj(val, type_info<Type>(), owner);
    }
  };

  template <class Type> struct traits_from {
    static PyObject *from(const Type& val) {
      return traits_from_ptr<Type>::from(new Type(val), 1);
    }
  };

  template <class Type> struct traits_from<Type *> {
    static PyObject *from(Type* val) {
      return traits_from_ptr<Type>::from(val, 0);
    }
  };

  template <class Type> struct traits_from<const Type *> {
    static PyObject *from(const Type* val) {
      return traits_from_ptr<Type>::from(const_cast<Type*>(val), 0);
    }
  };


  template <class Type>
  inline PyObject *from(const Type& val) {
    return traits_from<Type>::from(val);
  }

  template <class Type>
  inline PyObject *from_ptr(Type* val, int owner) {
    return traits_from_ptr<Type>::from(val, owner);
  }

  /*
    Traits that provides the asval/as/check method
  */
  template <class Type>
  struct traits_asptr {   
    static int asptr(PyObject *obj, Type **val) {
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
  inline int asptr(PyObject *obj, Type **vptr) {
    return traits_asptr<Type>::asptr(obj, vptr);
  }

  template <class Type> 
  struct traits_asval {
    static int asval(PyObject *obj, Type *val) {
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
    static int asval(PyObject *obj, Type **val) {
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
  inline int asval(PyObject *obj, Type *val) {
    return traits_asval<Type>::asval(obj, val);
  }

  template <class Type> 
  struct traits_as<Type, value_category> {
    static Type as(PyObject *obj) {
      Type v;
      int res = asval(obj, &v);
      if (!obj || !alaqil_IsOK(res)) {
	if (!PyErr_Occurred()) {
	  ::%type_error(alaqil::type_name<Type>());
	}
	throw std::invalid_argument("bad type");
      }
      return v;
    }
  };

  template <class Type> 
  struct traits_as<Type, pointer_category> {
    static Type as(PyObject *obj) {
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
	if (!PyErr_Occurred()) {
	  %type_error(alaqil::type_name<Type>());
	}
	throw std::invalid_argument("bad type");
      }
    }
  };

  template <class Type> 
  struct traits_as<Type*, pointer_category> {
    static Type* as(PyObject *obj) {
      Type *v = 0;      
      int res = (obj ? traits_asptr<Type>::asptr(obj, &v) : alaqil_ERROR);
      if (alaqil_IsOK(res)) {
	return v;
      } else {
	if (!PyErr_Occurred()) {
	  %type_error(alaqil::type_name<Type>());
	}
	throw std::invalid_argument("bad type");
      }
    }
  };
    
  template <class Type>
  inline Type as(PyObject *obj) {
    return traits_as<Type, typename traits<Type>::category>::as(obj);
  }

  template <class Type> 
  struct traits_check<Type, value_category> {
    static bool check(PyObject *obj) {
      int res = obj ? asval(obj, (Type *)(0)) : alaqil_ERROR;
      return alaqil_IsOK(res) ? true : false;
    }
  };

  template <class Type> 
  struct traits_check<Type, pointer_category> {
    static bool check(PyObject *obj) {
      int res = obj ? asptr(obj, (Type **)(0)) : alaqil_ERROR;
      return alaqil_IsOK(res) ? true : false;
    }
  };

  template <class Type>
  inline bool check(PyObject *obj) {
    return traits_check<Type, typename traits<Type>::category>::check(obj);
  }
}
}

//
// Backward compatibility
//

#ifdef alaqil_PYTHON_BACKWARD_COMP
%fragment("<string>");
%{
PyObject* alaqilInt_FromBool(bool b) {
    return PyInt_FromLong(b ? 1L : 0L);
}
double alaqilNumber_Check(PyObject* o) {
    return PyFloat_Check(o) || PyInt_Check(o) || PyLong_Check(o);
}
double alaqilNumber_AsDouble(PyObject* o) {
    return PyFloat_Check(o) ? PyFloat_AsDouble(o)
        : (PyInt_Check(o) ?   double(PyInt_AsLong(o))
                            : double(PyLong_AsLong(o)));
}
PyObject* alaqilString_FromString(const std::string& s) {
    return PyString_FromStringAndSize(s.data(),s.size());
}
std::string alaqilString_AsString(PyObject* o) {
    return std::string(PyString_AsString(o));
}
%}

#endif


%define %specialize_std_container(Type,Check,As,From)
%{
namespace alaqil {
  template <>  struct traits_asval<Type > {   
    typedef Type value_type;
    static int asval(PyObject *obj, value_type *val) {
      if (Check(obj)) {
	if (val) *val = As(obj);
	return alaqil_OK;
      }
      return alaqil_ERROR;
    }
  };
  template <>  struct traits_from<Type > {
    typedef Type value_type;
    static PyObject *from(const value_type& val) {
      return From(val);
    }
  };

  template <> 
  struct traits_check<Type, value_category> {
    static int check(PyObject *obj) {
      int res = Check(obj);
      return obj && res ? res : 0;
    }
  };
}
%}
%enddef


#define specialize_std_vector(Type,Check,As,From) %specialize_std_container(%arg(Type),Check,As,From)
#define specialize_std_list(Type,Check,As,From) %specialize_std_container(%arg(Type),Check,As,From)
#define specialize_std_deque(Type,Check,As,From) %specialize_std_container(%arg(Type),Check,As,From)
#define specialize_std_set(Type,Check,As,From) %specialize_std_container(%arg(Type),Check,As,From)
#define specialize_std_multiset(Type,Check,As,From) %specialize_std_container(%arg(Type),Check,As,From)
#define specialize_std_unordered_set(Type,Check,As,From) %specialize_std_container(%arg(Type),Check,As,From)
#define specialize_std_unordered_multiset(Type,Check,As,From) %specialize_std_container(%arg(Type),Check,As,From)
