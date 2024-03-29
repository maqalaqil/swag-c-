%module(ruby_minherit="1") using_composition

%warnfilter(alaqilWARN_JAVA_MULTIPLE_INHERITANCE,
	    alaqilWARN_CSHARP_MULTIPLE_INHERITANCE,
	    alaqilWARN_D_MULTIPLE_INHERITANCE,
	    alaqilWARN_PHP_MULTIPLE_INHERITANCE) FooBar;   // C#, D, Java, PHP multiple inheritance
%warnfilter(alaqilWARN_JAVA_MULTIPLE_INHERITANCE,
	    alaqilWARN_CSHARP_MULTIPLE_INHERITANCE,
	    alaqilWARN_D_MULTIPLE_INHERITANCE,
	    alaqilWARN_PHP_MULTIPLE_INHERITANCE) FooBar2;   // C#, D, Java, PHP multiple inheritance
%warnfilter(alaqilWARN_JAVA_MULTIPLE_INHERITANCE,
	    alaqilWARN_CSHARP_MULTIPLE_INHERITANCE,
	    alaqilWARN_D_MULTIPLE_INHERITANCE,
	    alaqilWARN_PHP_MULTIPLE_INHERITANCE) FooBar3;   // C#, D, Java, PHP multiple inheritance
#ifdef alaqilLUA	// lua only has one numeric type, so some overloads shadow each other creating warnings
%warnfilter(alaqilWARN_LANG_OVERLOAD_SHADOW) blah;
#endif

%inline %{
class Foo {
public:
     int blah(int x) { return x; }
     char *blah(char *x) { return x; }
};

class Bar {
public:
     double blah(double x) { return x; }
};

class FooBar : public Foo, public Bar {
public:
     using Foo::blah;
     using Bar::blah;
     char *blah(char *x) { return x; }
};

class FooBar2 : public Foo, public Bar {
public:
     char *blah(char *x) { return x; }
     using Foo::blah;
     using Bar::blah;
};

class FooBar3 : public Foo, public Bar {
public:
     using Foo::blah;
     char *blah(char *x) { return x; }
     using Bar::blah;
};

%}
