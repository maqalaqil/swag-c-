%typemap(throws,noblock=1) (...) {
  alaqil_exception(alaqil_RuntimeError,"unknown exception");
}

%insert("runtime") %{
#define alaqil_exception(code, msg) _alaqil_gopanic(msg)
%}
