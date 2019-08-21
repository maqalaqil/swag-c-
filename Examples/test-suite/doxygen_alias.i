%module doxygen_alias

#ifdef alaqilJAVA
%feature("doxygen:alias:nullptr") "null"
#elif defined(alaqilPYTHON)
%feature("doxygen:alias:nullptr") "None"
#else
%feature("doxygen:alias:nullptr") "NULL"
#endif

%inline %{

class Something {};

/**
    A function returning something.

    @returns A new object which may be @nullptr.
 */
Something* make_something() { return 0; }

%}
