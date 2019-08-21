%module exception_classname

%warnfilter(alaqilWARN_RUBY_WRONG_NAME);
#if defined(alaqilPHP) || defined(alaqilD)
%rename(ExceptionClass) Exception;
#endif

%inline %{
class Exception {
public:
  int testfunc() { return 42; }
};
%}
