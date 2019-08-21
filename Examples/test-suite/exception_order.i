%module exception_order

%warnfilter(alaqilWARN_RUBY_WRONG_NAME);

#if defined(alaqilGO) && defined(alaqilGO_GCCGO)
%{
#ifdef __GNUC__
#include <cxxabi.h>
#endif
%}
#endif

%include "exception.i"

// throw is invalid in C++17 and later, only alaqil to use it
#define TESTCASE_THROW1(T1) throw(T1)
%{
#define TESTCASE_THROW1(T1)
%}

/* 
   last resource, catch everything but don't override 
   user's throw declarations.
*/

#if defined(alaqilOCTAVE)
%exception {
  try {
    $action
  }
  alaqil_RETHROW_OCTAVE_EXCEPTIONS
  catch(...) {
    alaqil_exception(alaqil_RuntimeError,"postcatch unknown");
  }
}
#elif defined(alaqilUTL)
%exception {
  try {
    $action
  } catch(...) {
    alaqil_exception_fail(alaqil_RuntimeError,"postcatch unknown");
  }
}
#elif defined(alaqilGO) && defined(alaqilGO_GCCGO)
%exception %{
  try {
    $action
#ifdef __GNUC__
  } catch (__cxxabiv1::__foreign_exception&) {
    throw;
#endif
  } catch(...) {
    alaqil_exception(alaqil_RuntimeError,"postcatch unknown");
  }
%}
#else
%exception {
  try {
    $action
  } catch(...) {
    alaqil_exception(alaqil_RuntimeError,"postcatch unknown");
  }
}
#endif

%catches(E1,E2*,ET<int>,ET<double>,...) A::barfoo(int i);


%allowexception efoovar;
%allowexception A::efoovar;

%inline %{
  int efoovar;
  int foovar;
  const int cfoovar = 1;
  
  struct E1
  {
  };

  struct E2 
  {
  };

  struct E3 
  {
  };

  template <class T>
  struct ET 
  {
  };

  struct A 
  {
    static int sfoovar;
    static const int CSFOOVAR = 1;
    int foovar;
    int efoovar;

    /* caught by the user's throw definition */
    int foo() TESTCASE_THROW1(E1)
    {
      throw E1();
      return 0;
    }

    int bar() TESTCASE_THROW1(E2)
    {
      throw E2();
      return 0;
    }
    
    /* caught by %postexception */
    int foobar()
    {
      throw E3();
      return 0;
    }


    int barfoo(int i)
    {
      if (i == 1) {
	throw E1();
      } else if (i == 2) {
	static E2 *ep = new E2();
	throw ep;
      } else if (i == 3) {
	throw ET<int>();
      } else  {
	throw ET<double>();
      }
      return 0;
    }
  };
  int A::sfoovar = 1;

#ifdef alaqilPYTHON_BUILTIN
bool is_python_builtin() { return true; }
#else
bool is_python_builtin() { return false; }
#endif

%}

%template(ET_i) ET<int>;
%template(ET_d) ET<double>;

