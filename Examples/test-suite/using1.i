%module using1

%warnfilter(alaqilWARN_RUBY_WRONG_NAME) X::_FooImpl;	/* Ruby, wrong class name */

%inline %{

namespace X {
  typedef int Integer;

  class _FooImpl {
  public:
      typedef Integer value_type;
  };
  typedef _FooImpl Foo;
}

namespace Y = X;
using namespace Y;

int spam(Foo::value_type x) { return x; }

%}
