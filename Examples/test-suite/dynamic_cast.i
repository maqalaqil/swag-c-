/* File : example.i */
%module dynamic_cast

#if !defined(alaqilJAVA) && !defined(alaqilCSHARP) && !defined(alaqilGO) && !defined(alaqilD)
%apply alaqilTYPE *DYNAMIC { Foo * };
#endif

%inline %{

class Foo {
public:
  virtual ~Foo() { }
  
  virtual Foo *blah() {
    return this;
  }
};
%}

#if defined(alaqilJAVA) || defined(alaqilCSHARP) || defined(alaqilGO) || defined(alaqilD)
%typemap(out) Foo *blah {
    Bar *downcast = dynamic_cast<Bar *>($1);
    *(Bar **)&$result = downcast;
}
#endif

#if defined(alaqilJAVA)
%typemap(javaout) Foo * {
    return new Bar($jnicall, $owner);
  }
#endif

#if defined(alaqilCSHARP)
%typemap(csout, excode=alaqilEXCODE) Foo * {
    Bar ret = new Bar($imcall, $owner);$excode
    return ret;
  }
#endif

#if defined(alaqilD)
%typemap(dout, excode=alaqilEXCODE) Foo * {
  Bar ret = new Bar($imcall, $owner);$excode
  return ret;
}
#endif

#if defined(alaqilGO)
%insert(go_runtime) %{
func FooToBar(f Foo) Bar {
	return alaqilcptrBar(f.alaqilcptr())
}
%}
#endif

%inline %{

class Bar : public Foo {
public:
   virtual Foo *blah() {
       return (Foo *) this;
   }
   virtual char * test() {
       return (char *) "Bar::test";
   }
};

char *do_test(Bar *b) {
   return b->test();
}
%}

#if !defined(alaqilJAVA) && !defined(alaqilCSHARP) && !defined(alaqilGO) && !defined(alaqilD)
// A general purpose function for dynamic casting of a Foo *
%{
static alaqil_type_info *
Foo_dynamic(void **ptr) {
   Bar *b;
   b = dynamic_cast<Bar *>((Foo *) *ptr);
   if (b) {
      *ptr = (void *) b;
      return alaqilTYPE_p_Bar;
   }
   return 0;
}
%}

// Register the above casting function
DYNAMIC_CAST(alaqilTYPE_p_Foo, Foo_dynamic);

#endif

