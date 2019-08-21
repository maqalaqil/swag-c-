%module template_typemaps


%typemap(in) Integer1 
{
  $1 = 0;
  /* do nothing */
}

#ifdef alaqilCSHARP
%typemap(out) Integer1 { /* do nothing */ $result = 0; }
#else
%typemap(out) Integer1 { /* do nothing */ }
#endif

%typemap(in) Integer2 
{
  $1 = 0;
  /* do nothing */
}

#ifdef alaqilCSHARP
%typemap(out) Integer2 { /* do nothing */ $result = 0; }
#else
%typemap(out) Integer2 { /* do nothing */ }
#endif

#ifdef alaqilOCAML
%warnfilter(alaqilWARN_PARSE_KEYWORD) val;
#endif

%{
  typedef int Integer1;
%}


%inline %{
  typedef int Integer2;

  template <class T>
    struct Foo 
    {
      T val;
      
      T get_value() const 
      {
	return val;
      }

      void set_value(T v) 
      {
	val = v;
      }

#ifdef alaqil
       %typemap(in) Foo* "/* in typemap for Foo, with type T */" 
#endif
    };  
%}

%template(Foo_I1) Foo<Integer1>;
%template(Foo_I2) Foo<Integer2>;

%inline %{
  int bar(Foo<Integer1> *foo) {
    return 0;
  }  
%}

  
