/* This interface file tests whether alaqil handles types like
   "const int *const" right.

   alaqil 1.3a5 signals a syntax error.
*/

%module const_const

%typemap(in) const int *const { $1 = NULL; }

%inline %{
void foo(const int *const i) {}
%}
