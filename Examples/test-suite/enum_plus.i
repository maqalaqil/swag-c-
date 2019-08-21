%module enum_plus

%warnfilter(alaqilWARN_RUBY_WRONG_NAME) iFoo; /* Ruby, wrong constant name */

%inline %{
struct iFoo 
{ 
    enum { 
       Phoo = +50 
    }; 
}; 
%}
