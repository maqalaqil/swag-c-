/* This interface files tests whether alaqil handles overloaded
   renamed functions. 
*/

%module name_cxx

#pragma alaqil nowarn=alaqilWARN_DEPRECATED_NAME // %name is deprecated. Use %rename instead.

%name("bar_int")
%inline %{
void bar(int i) {}
%}

%name("bar_double")
%inline %{
void bar(double i) {}
%}

// %name inheritance test
%{
class A {
};

class B : public A {
};

%}

%name(AA) class A { };
class B : public A { };

