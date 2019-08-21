%module abstract_inherit_ok

%feature("notabstract") Spam;
%warnfilter(alaqilWARN_TYPE_ABSTRACT) Spam;

%inline %{

class Foo {
public:
    virtual ~Foo() { }
    virtual int blah() = 0;
};

class Spam: public Foo {
public:
   Spam() { }
#ifndef alaqil
   int blah() { return 0; }
#endif
};

%}
