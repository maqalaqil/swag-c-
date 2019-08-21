// This is a helper file for shared_ptr and should not be included directly.

// The main implementation detail in using this smart pointer of a type is to customise the code generated
// to use a pointer to the smart pointer of the type, rather than the usual pointer to the underlying type.
// So for some type T, shared_ptr<T> * is used rather than T *.

// Another key part of the implementation is the smartptr feature:
//   %feature("smartptr") T { shared_ptr<T> }
// This feature marks the class T as having a smartptr to it (the shared_ptr<T> type). This is then used to
// support smart pointers and inheritance. Say class D derives from base B, then shared_ptr<D> is marked
// with a fake inheritance from shared_ptr<B> in the type system if the "smartptr" feature is used on both
// B and D. This is to emulate the conversion of shared_ptr<D> to shared_ptr<B> in the target language.

// shared_ptr namespaces could be boost or std or std::tr1
// For example for std::tr1, use:
// #define alaqil_SHARED_PTR_NAMESPACE std
// #define alaqil_SHARED_PTR_SUBNAMESPACE tr1

#if !defined(alaqil_SHARED_PTR_NAMESPACE)
# define alaqil_SHARED_PTR_NAMESPACE boost
#endif

#if defined(alaqil_SHARED_PTR_SUBNAMESPACE)
# define alaqil_SHARED_PTR_QNAMESPACE alaqil_SHARED_PTR_NAMESPACE::alaqil_SHARED_PTR_SUBNAMESPACE
#else
# define alaqil_SHARED_PTR_QNAMESPACE alaqil_SHARED_PTR_NAMESPACE
#endif

namespace alaqil_SHARED_PTR_NAMESPACE {
#if defined(alaqil_SHARED_PTR_SUBNAMESPACE)
  namespace alaqil_SHARED_PTR_SUBNAMESPACE {
#endif
    template <class T> class shared_ptr {
    };
#if defined(alaqil_SHARED_PTR_SUBNAMESPACE)
  }
#endif
}

%fragment("alaqil_null_deleter", "header") {
struct alaqil_null_deleter {
  void operator() (void const *) const {
  }
};
%#define alaqil_NO_NULL_DELETER_0 , alaqil_null_deleter()
%#define alaqil_NO_NULL_DELETER_1
%#define alaqil_NO_NULL_DELETER_alaqil_POINTER_NEW
%#define alaqil_NO_NULL_DELETER_alaqil_POINTER_OWN
}


// Main user macro for defining shared_ptr typemaps for both const and non-const pointer types
%define %shared_ptr(TYPE...)
%feature("smartptr", noblock=1) TYPE { alaqil_SHARED_PTR_QNAMESPACE::shared_ptr< TYPE > }
alaqil_SHARED_PTR_TYPEMAPS(, TYPE)
alaqil_SHARED_PTR_TYPEMAPS(const, TYPE)
%enddef

// Legacy macros
%define alaqil_SHARED_PTR(PROXYCLASS, TYPE...)
#warning "alaqil_SHARED_PTR(PROXYCLASS, TYPE) is deprecated. Please use %shared_ptr(TYPE) instead."
%shared_ptr(TYPE)
%enddef

%define alaqil_SHARED_PTR_DERIVED(PROXYCLASS, BASECLASSTYPE, TYPE...)
#warning "alaqil_SHARED_PTR_DERIVED(PROXYCLASS, BASECLASSTYPE, TYPE) is deprecated. Please use %shared_ptr(TYPE) instead."
%shared_ptr(TYPE)
%enddef

