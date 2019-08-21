// Based on https://github.com/alaqil/alaqil/issues/339 .

%module inherit_member

%include <std_string.i>

%inline %{

struct parent_class {
  std::string pvar;
};

 struct child : public parent_class {
  std::string cvar;
};

%}
