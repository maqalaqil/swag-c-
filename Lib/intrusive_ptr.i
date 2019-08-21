// Allow for different namespaces for shared_ptr / intrusive_ptr - they could be boost or std or std::tr1
// For example for std::tr1, use:
// #define alaqil_SHARED_PTR_NAMESPACE std
// #define alaqil_SHARED_PTR_SUBNAMESPACE tr1
// #define alaqil_INTRUSIVE_PTR_NAMESPACE boost
// #define alaqil_INTRUSIVE_PTR_SUBNAMESPACE 

#if !defined(alaqil_INTRUSIVE_PTR_NAMESPACE)
# define alaqil_INTRUSIVE_PTR_NAMESPACE boost
#endif

#if defined(alaqil_INTRUSIVE_PTR_SUBNAMESPACE)
# define alaqil_INTRUSIVE_PTR_QNAMESPACE alaqil_INTRUSIVE_PTR_NAMESPACE::alaqil_INTRUSIVE_PTR_SUBNAMESPACE
#else
# define alaqil_INTRUSIVE_PTR_QNAMESPACE alaqil_INTRUSIVE_PTR_NAMESPACE
#endif

namespace alaqil_INTRUSIVE_PTR_NAMESPACE {
#if defined(alaqil_INTRUSIVE_PTR_SUBNAMESPACE)
  namespace alaqil_INTRUSIVE_PTR_SUBNAMESPACE {
#endif
    template <class T> class intrusive_ptr {
    };
#if defined(alaqil_INTRUSIVE_PTR_SUBNAMESPACE)
  }
#endif
}

%fragment("alaqil_intrusive_deleter", "header") {
template<class T> struct alaqil_intrusive_deleter {
    void operator()(T *p) {
        if (p) 
          intrusive_ptr_release(p);
    }
};
}

%fragment("alaqil_null_deleter", "header") {
struct alaqil_null_deleter {
  void operator() (void const *) const {
  }
};
%#define alaqil_NO_NULL_DELETER_0 , alaqil_null_deleter()
%#define alaqil_NO_NULL_DELETER_1
}

// Main user macro for defining intrusive_ptr typemaps for both const and non-const pointer types
%define %intrusive_ptr(TYPE...)
%feature("smartptr", noblock=1) TYPE { alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > }
alaqil_INTRUSIVE_PTR_TYPEMAPS(, TYPE)
alaqil_INTRUSIVE_PTR_TYPEMAPS(const, TYPE)
%enddef

%define %intrusive_ptr_no_wrap(TYPE...)
%feature("smartptr", noblock=1) TYPE { alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > }
alaqil_INTRUSIVE_PTR_TYPEMAPS_NO_WRAP(, TYPE)
alaqil_INTRUSIVE_PTR_TYPEMAPS_NO_WRAP(const, TYPE)
%enddef

// Legacy macros
%define alaqil_INTRUSIVE_PTR(PROXYCLASS, TYPE...)
#warning "alaqil_INTRUSIVE_PTR(PROXYCLASS, TYPE) is deprecated. Please use %intrusive_ptr(TYPE) instead."
%intrusive_ptr(TYPE)
%enddef

%define alaqil_INTRUSIVE_PTR_DERIVED(PROXYCLASS, BASECLASSTYPE, TYPE...)
#warning "alaqil_INTRUSIVE_PTR_DERIVED(PROXYCLASS, BASECLASSTYPE, TYPE) is deprecated. Please use %intrusive_ptr(TYPE) instead."
%intrusive_ptr(TYPE)
%enddef

%define alaqil_INTRUSIVE_PTR_NO_WRAP(PROXYCLASS, TYPE...)
#warning "alaqil_INTRUSIVE_PTR_NO_WRAP(PROXYCLASS, TYPE) is deprecated. Please use %intrusive_ptr_no_wrap(TYPE) instead."
%intrusive_ptr_no_wrap(TYPE)
%enddef

%define alaqil_INTRUSIVE_PTR_DERIVED_NO_WRAP(PROXYCLASS, BASECLASSTYPE, TYPE...)
#warning "alaqil_INTRUSIVE_PTR_DERIVED_NO_WRAP(PROXYCLASS, BASECLASSTYPE, TYPE) is deprecated. Please use %intrusive_ptr_no_wrap(TYPE) instead."
%intrusive_ptr_no_wrap(TYPE)
%enddef

