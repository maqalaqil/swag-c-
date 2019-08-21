%module(directors="1") director_exception_catches

%include <std_string.i>
%feature("director") BaseClass;

%{
// define dummy director exception classes to prevent spurious errors 
// in target languages that do not support directors.

#ifndef alaqil_DIRECTORS
namespace alaqil {
  class DirectorException {};
}
#endif /* !alaqil_DIRECTORS */
%}

%catches(alaqil::DirectorException) BaseClass::call_description;

%inline %{
struct BaseClass {
  virtual std::string description() const = 0;
  static std::string call_description(BaseClass& bc) { return bc.description(); }
  virtual ~BaseClass() {}
};
%}
