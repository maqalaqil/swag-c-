%module(ruby_minherit="1") evil_diamond

%warnfilter(alaqilWARN_RUBY_WRONG_NAME) foo;		// Ruby, wrong class name
%warnfilter(alaqilWARN_RUBY_WRONG_NAME) bar;		// Ruby, wrong class name
%warnfilter(alaqilWARN_RUBY_WRONG_NAME) baz;		// Ruby, wrong class name
%warnfilter(alaqilWARN_RUBY_WRONG_NAME,
	    alaqilWARN_JAVA_MULTIPLE_INHERITANCE,
	    alaqilWARN_CSHARP_MULTIPLE_INHERITANCE,
	    alaqilWARN_D_MULTIPLE_INHERITANCE,
	    alaqilWARN_PHP_MULTIPLE_INHERITANCE) spam;	// Ruby, wrong class name - C#, D & Java, PHP multiple inheritance

%inline %{

class foo { };

class bar : public foo {
};

class baz : public foo {
};

class spam : public bar, public baz {
};

foo *test(foo *f) { return f; }
%}

