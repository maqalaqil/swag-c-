%module typemap_delete

#ifdef alaqilOCAML
%warnfilter(alaqilWARN_PARSE_KEYWORD) val;
#endif

%typemap(in) Rect* (Rect temp) {
  $1 = 0;
  will_not_compile
}

%typemap(in) Rect*;

%inline %{
struct Rect
{
  int val;
  Rect(int v) : val(v) {}
};
%}
