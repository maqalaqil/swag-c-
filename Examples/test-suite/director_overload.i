%module(directors="1") director_overload

#ifdef alaqilOCAML
%warnfilter(alaqilWARN_PARSE_KEYWORD) method;
#endif

%feature("director");

#ifdef alaqilPYTHON
%feature("director:except") {
  if ($error != NULL) {
    throw alaqil::DirectorMethodException();
  }
}
#endif

#ifdef alaqilRUBY
// Catch ruby exceptions in directors
%feature("director:except") {
 throw alaqil::DirectorMethodException($error);
}
#endif

%inline %{

class OverloadedClass
{
public:
  virtual ~OverloadedClass() {}
  virtual void method1() const {}
  virtual void method2() const {}
  virtual void method3() const {}
  // test overloaded method, but not directly after the first method
  virtual void method2(bool b) const {}
};

class OverloadedPointers
{
public:
  virtual ~OverloadedPointers() {}
  virtual void method(int *p) const {}
  virtual void method(double *p) const {}
  virtual void method(bool &r) const {}
  virtual void method(short &r) const {}
  virtual void method(OverloadedClass *p) const {}
  virtual void method(OverloadedPointers *p) const {}
  virtual void notover(int *p) const {}
};

%}

