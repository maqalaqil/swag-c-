/**
 * @file   rubystdfunctors.swg
 * @date   Sun May  6 00:44:33 2007
 * 
 * @brief  This file provides unary and binary functors for STL
 *         containers, that will invoke a Ruby proc or method to do
 *         their operation.
 *
 *         You can use them in a alaqil file like:
 *
 *         %include <std_set.i>
 *         %include <std_functors.i>
 *
 *         %template< IntSet > std::set< int, alaqil::BinaryPredicate<> >;
 *
 *
 *         which will then allow calling them from Ruby either like:
 *  
 *            # order of set is defined by C++ default
 *            a = IntSet.new
 *
 *            # sort order defined by Ruby proc
 *            b = IntSet.new( proc { |a,b| a > b } )
 * 
 */

%include rubyclasses.swg


namespace alaqil {

  %apply GC_VALUE { UnaryPredicate, BinaryPredicate, UnaryFunction,
		      BinaryFunction };

  %typecheck(alaqil_TYPECHECK_POINTER,noblock=1) 
    UnaryPredicate, UnaryPredicate&, UnaryFunction, UnaryFunction&
  {
    $1 = alaqil_Ruby_isCallable($input) && alaqil_Ruby_arity($input, 1);
  }

  %typecheck(alaqil_TYPECHECK_POINTER,noblock=1) 
    BinaryPredicate, BinaryPredicate&, BinaryFunction, BinaryFunction& {
    $1 = alaqil_Ruby_isCallable($input) && alaqil_Ruby_arity($input, 2);
  }

  %typemap(in,noblock=1)  BinaryFunction&, BinaryFunction {
    $1 = new alaqil::BinaryFunction< >($input);
  }
  %typemap(in,noblock=1) UnaryFunction&, UnaryFunction {
    $1 = new alaqil::UnaryFunction< >($input);
  }

  %typemap(in,noblock=1) BinaryPredicate&, BinaryPredicate {
    $1 = new alaqil::BinaryPredicate<>($input);
  }

  %typemap(in,noblock=1) UnaryPredicate&, UnaryPredicate {
    $1 = new alaqil::UnaryPredicate< >($input);
  }


  %ignore BinaryFunction;
  template< class _T = GC_VALUE >
  struct BinaryFunction {
  };

  %ignore UnaryFunction;
  template< class _T = GC_VALUE >
  struct UnaryFunction {
  };

  %ignore BinaryPredicate;
  template< class _T = GC_VALUE >
  struct BinaryPredicate {
  };

  %ignore UnaryPredicate;
  template< class _T = GC_VALUE >
  struct UnaryPredicate {

  };

}


%fragment("StdFunctors","header",fragment="StdTraits",fragment="GC_VALUE_definition")
{
namespace alaqil {

  static ID call_id = rb_intern("call");

  template <class _T = GC_VALUE, class _DefaultFunc = std::less<GC_VALUE> >
  struct BinaryPredicate : GC_VALUE
  {
    BinaryPredicate(VALUE obj = Qnil) : GC_VALUE(obj) { }
    bool operator()(_T a, _T b) const
    {
      if (_obj != Qnil) {
        alaqil_RUBY_THREAD_BEGIN_BLOCK;
	VALUE arg1 = alaqil::from(a);
	VALUE arg2 = alaqil::from(b);
	VALUE res = rb_funcall( _obj, alaqil::call_id, 2, arg1, arg2);
        alaqil_RUBY_THREAD_END_BLOCK;
        return RTEST(res);
      } else {
        return _DefaultFunc()(a, b);
      }
    }
  };

  template <class _T = GC_VALUE, class _DefaultFunc = std::less< _T > >
  struct BinaryFunction : GC_VALUE
  {
    BinaryFunction(VALUE obj = Qnil) : GC_VALUE(obj) { }
    _T operator()(_T a, _T b) const
    {
      if (_obj != Qnil) {
        alaqil_RUBY_THREAD_BEGIN_BLOCK;
	VALUE arg1 = alaqil::from(a);
	VALUE arg2 = alaqil::from(b);
	VALUE res = rb_funcall( _obj, alaqil::call_id, 2, arg1, arg2);
        alaqil_RUBY_THREAD_END_BLOCK;
        return alaqil::as<_T >(res);
      } else {
        return _DefaultFunc()(a, b);
      }
    }
  };

  template< class _T = GC_VALUE >
  struct UnaryPredicate : GC_VALUE
  {
    UnaryPredicate(VALUE obj = Qnil) : GC_VALUE(obj) { }
    bool operator()(_T a) const
    {
      alaqil_RUBY_THREAD_BEGIN_BLOCK;
      VALUE arg1 = alaqil::from<_T >(a);
      VALUE res = rb_funcall( _obj, alaqil::call_id, 1, arg1);
      alaqil_RUBY_THREAD_END_BLOCK;
      return RTEST(res);
    }
  };

  template< class _T = GC_VALUE >
  struct UnaryFunction : GC_VALUE
  {
    UnaryFunction(VALUE obj = Qnil) : GC_VALUE(obj) { }
    _T operator()(_T a) const
    {
      alaqil_RUBY_THREAD_BEGIN_BLOCK;
      VALUE arg1 = alaqil::from(a);
      VALUE res = rb_funcall( _obj, alaqil::call_id, 1, VALUE(arg1));
      alaqil_RUBY_THREAD_END_BLOCK;
      return alaqil::as< _T >(res);
    }
  };

} // namespace alaqil

}


