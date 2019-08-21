%module(ruby_minherit="1") using_extend

%warnfilter(alaqilWARN_JAVA_MULTIPLE_INHERITANCE,
	    alaqilWARN_CSHARP_MULTIPLE_INHERITANCE,
	    alaqilWARN_D_MULTIPLE_INHERITANCE,
	    alaqilWARN_PHP_MULTIPLE_INHERITANCE) FooBar;   // C#, D, Java, PHP multiple inheritance
#ifdef alaqilLUA	// lua only has one numeric type, so some overloads shadow each other creating warnings
%warnfilter(alaqilWARN_LANG_OVERLOAD_SHADOW) blah;
#endif

%extend Foo {
     int blah(int x, int y) {
        return x+y;
     }
};

%extend Bar {
     double blah(double x, double y) {
        return x+y;
     }
};

%inline %{
class Foo {
public:
     int blah(int x) { return x; }
     char *blah(char *x) { return x; }
};

class Bar {
public:
     int duh1() { return 1; }
     int duh(int x) { return x; }
     double blah(double x) { return x; }
};

class FooBar : public Foo, public Bar {
public:
     using Foo::blah;
     using Bar::blah;
     char *blah(char *x) { return x; }
};

%}

%extend FooBar 
{
  using Bar::duh1;
  using Bar::duh;
}


