/* File : example.i */
%module example

%typemap(argout) (const int &x, const int &y) {
  alaqil_result = caml_list_append(alaqil_result, caml_val_int(*$1));
  alaqil_result = caml_list_append(alaqil_result, caml_val_int(*$2));
}

%{
extern "C" void factor(const int &x, const int &y);
%}

extern "C" void factor(const int &x, const int &y);
