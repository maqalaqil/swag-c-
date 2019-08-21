%module input

%apply int *INPUT {int *bar};

%typemap(out, fragment=alaqil_From_frag(int)) int *foo {
  if ($1) {
    $result = alaqil_From(int)(*$1);
  } else {
    $result = alaqil_Py_Void();
  }
}

%inline 
{
  struct Foo {
    int *foo(int *bar = 0) {
      if (bar) {
	*bar *= 2;
      }
      return (bar) ? bar : 0;
    }
  };
}

%include std_string.i
%apply std::string *INPUT {std::string *bar};

%typemap(out, fragment=alaqil_From_frag(std::string)) std::string *sfoo {
  if ($1) {
    $result = alaqil_From(std::string)(*$1);
  } else {
    $result = alaqil_Py_Void();
  }
}

%inline %{
  std::string *sfoo(std::string *bar = 0) {
    if (bar) *bar += " world";
    return (bar) ? bar : 0;
  }
%}
