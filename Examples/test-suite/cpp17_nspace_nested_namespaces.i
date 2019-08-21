%module cpp17_nspace_nested_namespaces

#if defined(alaqilJAVA)
alaqil_JAVABODY_PROXY(public, public, alaqilTYPE)
#endif

// nspace feature only supported by these languages
#if defined(alaqilJAVA) || defined(alaqilCSHARP) || defined(alaqilD) || defined(alaqilLUA) || defined(alaqilJAVASCRIPT)
%nspace;
#endif


%include "cpp17_nested_namespaces.i"
