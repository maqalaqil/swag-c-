/*
 * a test of set containers.
 * Languages should define alaqil::LANGUAGE_OBJ to be
 * an entity of their native pointer type which can be
 * included in a STL container.
 *
 * For example:
 *   alaqil::LANGUAGE_OBJ  is  GC_VALUE in Ruby
 *   alaqil::LANGUAGE_OBJ  is  alaqilPtr_PyObject in python
 */

%module li_std_set

%include <std_string.i>
%include <std_set.i>
%include <std_vector.i>

// Use language macros since Java and C# don't have multiset support (yet)
// and uses different naming conventions.
#if defined(alaqilRUBY) || defined(alaqilPYTHON)
    %include <std_multiset.i>
    %template(set_int) std::multiset<int>;
    %template(v_int) std::vector<int>;
    %template(set_string) std::set<std::string>;
#elif defined(alaqilJAVA) || defined(alaqilCSHARP)
    %template(StringSet) std::set<std::string>;
#endif

#if defined(alaqilRUBY)
%template(LanguageSet) std::set<alaqil::LANGUAGE_OBJ>;
#endif

#if defined(alaqilPYTHON)
%template(pyset) std::set<alaqil::alaqilPtr_PyObject>;
#endif
