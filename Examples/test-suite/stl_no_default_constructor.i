%module stl_no_default_constructor

%include <stl.i>

%inline %{
struct NoDefaultCtor {
  int value;
  NoDefaultCtor(int i) : value(i) {}
};
%}

#if defined(alaqilCSHARP) || defined(alaqilJAVA) || defined(alaqilD)
%template(VectorNoDefaultCtor) std::vector<NoDefaultCtor>;
#endif

#if defined(alaqilJAVA) || defined(alaqilJAVA)
%include <std_list.i>
%template(ListNoDefaultCtor) std::list<NoDefaultCtor>;
#endif
